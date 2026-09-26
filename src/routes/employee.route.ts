import express from 'express';
import {
  readAllEmployees,
  readEmployeeById,
} from '../controllers/employee.controller.ts';

const router = express.Router();

router.get('/', readAllEmployees);
router.get('/:id', readEmployeeById);

export default router;
