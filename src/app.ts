import express from 'express';
import cors from 'cors';
import { connectDB } from './config/db.ts';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT;

const startServer = async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}...`);
  });
};

startServer();
