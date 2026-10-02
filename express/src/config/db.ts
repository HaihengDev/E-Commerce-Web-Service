import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const uri = process.env.MONGO_URI;

export const connectDB = async (): Promise<void> => {
  try {
    if (!uri) {
      throw new Error('There is no mongo_uri configured.');
    }

    await mongoose.connect(uri);
    console.log('Mongo DB is connected.');
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};
