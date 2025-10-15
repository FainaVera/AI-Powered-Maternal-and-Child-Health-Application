const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());

// Basic request logger to help verify which server is handling requests
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

const GROQ_API_KEY = process.env.GROQ_API_KEY || 'enter_your_groq_api_key_here';
const GROQ_MODEL = process.env.GROQ_MODEL || 'llama3-8b-8192'; // Or any other suitable model

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('✅ MongoDB connected to Atlas'))
.catch(err => console.log('❌ MongoDB error:', err));

// Schemas
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true }
});
const User = mongoose.model('User', userSchema);

const childSchema = new mongoose.Schema({
  name: { type: String, required: true },
  age: Number,
  weight: Number,
  height: Number,
  gender: { type: String, required: true },
  nextAppointment: { type: String, required: true }
});
const ChildRecord = mongoose.model('ChildRecord', childSchema);

const pregnantSchema = new mongoose.Schema({
  name: { type: String, required: true },
  age: Number,
  weeks: Number,
  lastScan: String,
  nextAppointment: { type: String, required: true },
  bp: String,
  sugar: String
});
const PregnantRecord = mongoose.model('PregnantRecord', pregnantSchema);

// Signup
app.post('/signup', async (req, res) => {
  try {
    const { username, password } = req.body;
    const exists = await User.findOne({ username });
    if (exists) return res.status(400).json({ message: 'User already exists' });
    const user = new User({ username, password });
    await user.save();
    res.json({ message: 'Signup successful' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// Login
app.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username, password });
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });
    res.json({ message: 'Login successful' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// Add Child
app.post('/child', async (req, res) => {
  try {
    const { name, age, weight, height, gender, nextAppointment } = req.body;
    // Check for exact duplicate with all fields to prevent double submissions
    const exists = await ChildRecord.findOne({ 
      name, 
      age, 
      weight, 
      height, 
      gender, 
      nextAppointment 
    });

    if (exists) {
      return res.status(400).json({ message: 'Exact duplicate record found' });
    }
    const record = new ChildRecord(req.body);
    await record.save();
    res.status(201).json({ message: 'Child record added successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all Children
app.get('/child', async (req, res) => {
  try {
    const records = await ChildRecord.find();
    res.json(records);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// Add Pregnant
app.post('/pregnant', async (req, res) => {
  try {
    const { name, age, weeks, lastScan, nextAppointment, bp, sugar } = req.body;
    
    // Check for exact duplicate with all fields to prevent double submissions
    const exists = await PregnantRecord.findOne({ 
      name, 
      age, 
      weeks, 
      lastScan, 
      nextAppointment, 
      bp, 
      sugar 
    });
    
    if (exists) {
      return res.status(400).json({ message: 'Exact duplicate record found' });
    }
    const record = new PregnantRecord(req.body);
    await record.save();
    res.status(201).json({ message: 'Pregnant record added successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all Pregnant
app.get('/pregnant', async (req, res) => {
  try {
    const records = await PregnantRecord.find();
    res.json(records);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// AI based suggestions using Groq API
app.post('/ai/suggestions', async (req, res) => {
  try {
    console.log('POST /ai/suggestions');
    const { name, ageMonths, weightKg, heightCm, gender, assessments, overall } = req.body || {};

    // DONT CHNAGE ANYTHING HERE -> Reject if API key is not set (either missing env or still placeholder)
    if (!GROQ_API_KEY || GROQ_API_KEY === 'PASTE_YOUR_GROQ_API_KEY_HERE') {
      return res.status(500).json({ message: 'Missing GROQ_API_KEY (set env or replace placeholder in server.js)' });
    }

    // Build compact context string with z-scores
    const summary = (assessments || [])
      .map(a => `${a.category}: Z=${typeof a.zScore === 'number' ? a.zScore.toFixed(2) : a.zScore} (${a.status})`)
      .join('; ');

    const userContent = `Child: ${name ?? 'Unknown'} | Age: ${ageMonths ?? '?'} months | Gender: ${gender ?? '?'} | Weight: ${weightKg ?? '?'} kg | Height: ${heightCm ?? '?'} cm | Overall: ${overall || 'N/A'} | Assessments: ${summary || 'N/A'}`;

    // fetch fallback for Node < 18
    const doFetch = globalThis.fetch ? globalThis.fetch.bind(globalThis) : (await import('node-fetch')).default;

    const url = 'https://api.groq.com/openai/v1/chat/completions';
    const systemPrompt = 
    'You are a pediatric nutrition assistant. Using only the provided WHO-style growth summary (z-scores and overall status), provide 3-6 concise, actionable, culturally neutral lifestyle and nutrition suggestions. Avoid medical diagnoses or treatments. Use bullet points.';

    const payload = {
      model: 'llama-3.1-8b-instant',
      temperature: 0.4,
      max_tokens: 320,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userContent },
      ],
    };

    const response = await doFetch(url, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GROQ_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('Groq API error:', errText);
      return res.status(500).json({ message: 'Groq error', details: errText });
    }

    const data = await response.json();
    const text = data?.choices?.[0]?.message?.content?.trim?.();
    return res.json({ suggestions: text || '' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// Simple root route to confirm correct server is running
app.get('/', (req, res) => {
  res.json({ ok: true, service: 'BEA Backend', file: __filename, health: '/health', ai: '/ai/suggestions' });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    ok: true,
    aiProvider: 'groq',
    model: GROQ_MODEL,
    hasKey: !!GROQ_API_KEY && GROQ_API_KEY !== 'PASTE_YOUR_GROQ_API_KEY_HERE'   // DONT CHANGE
  });
});

// ---------------- START SERVER ----------------
const PORT = 3000;
const HOST = '0.0.0.0';
app.listen(PORT, HOST, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
  console.log(`➡️  File: ${__filename}`);
  console.log(`➡️  Health: http://localhost:${PORT}/health`);
  console.log(`➡️  AI:     http://localhost:${PORT}/ai/suggestions`);
  console.log(`➡️  GROQ key present: ${GROQ_API_KEY && GROQ_API_KEY !== 'PASTE_YOUR_GROQ_API_KEY_HERE'}`);    //DONT CHANGE
});
