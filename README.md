# pg_projection

![pg_projection logo](./logo.png)

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-v12+-blue.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![JSONB](https://img.shields.io/badge/JSONB-Native-orange.svg)]()

A lightweight PostgreSQL extension that brings **MongoDB-style Projections** to the `JSONB` data type. Optimized for read-only operations and performance, it allows you to filter JSON documents using a familiar syntax.

---

## 🚀 Installation

### From Source
```bash
make
sudo make install
```

### In PostgreSQL
Activate the extension in your database:
```sql
CREATE EXTENSION pg_projection;
```

---

## 🛠️ Usage

The extension provides functions to project fields based on a projection object where `1` means **include** and `0` means **exclude**.

### 1. Inclusion Mode
Returns only the specified fields. Note that `_id` is included by default unless explicitly set to `0`.

```sql
SELECT pg_project(data, '{"name": 1, "email": 1}') 
FROM agents;
-- Result: {"_id": "...", "name": "...", "email": "..."}
```

### 2. Exclusion Mode
Returns all fields except those marked with `0`.

```sql
SELECT pg_project(data, '{"internal_id": 0, "secret_key": 0}') 
FROM contacts;
-- Result: All fields except internal_id and secret_key
```

### 3. Query Set Projection
Transform the result of an entire query into a projected array of objects:

```sql
SELECT pg_project_set('SELECT * FROM users', '{"password": 0}');
-- Result: [{"id": 1, "username": "admin"}, ...]
```

---

## 💡 Why pg_projection?

- **Familiar Syntax**: If you know MongoDB, you already know how to use this.
- **Native JSONB Performance**: Leverages PostgreSQL's internal JSONB operators for speed.
- **Clean API**: Avoid complex `jsonb_build_object` chains for simple filtering.
- **Dynamic Projections**: Easily pass projections from your application layer directly to SQL.

---

## 📄 License
This project is licensed under the MIT License.
