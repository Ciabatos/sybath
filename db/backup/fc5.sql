ALTER TABLE tasks.tasks ALTER COLUMN scheduled_at TYPE timestamp USING scheduled_at::timestamp;
