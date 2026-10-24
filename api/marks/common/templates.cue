package common

exampleWidth: number & >0 & 360
exampleQuery: "SELECT * FROM (VALUES (1, 2, 'A', DATE '2024-01-01'), (1, 1, 'B', DATE '2024-01-01'), (2, 1, 'A', DATE '2024-01-02'), (2, 2, 'B', DATE '2024-01-02'), (3, 3, 'A', DATE '2024-01-03'), (3, 1, 'B', DATE '2024-01-03')) AS t(x, y, category, time)"
