import express from 'express';
import cors from 'cors';
import productRoute from './routes/product.route.ts';
import categoryRoute from './routes/category.route.ts';
import orderRoute from './routes/order.rotue.ts';
import customerRoute from './routes/customer.route.ts';
import employeeRoute from './routes/employee.route.ts';
import userRoute from './routes/user.route.ts';
import dotenv from 'dotenv';
import { connectDB } from './config/db.ts';
dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());
app.use('/api/v1/products', productRoute);
app.use('/api/v1/categories', categoryRoute);
app.use('/api/v1/orders', orderRoute);
app.use('/api/v1/customers', customerRoute);
app.use('/api/v1/auth', userRoute);
app.use('/api/v1/employee', employeeRoute);

const PORT = process.env.PORT;

const startServer = async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}...`);
  });
};

startServer();
