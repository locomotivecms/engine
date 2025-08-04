// MongoDB initialization script for LocomotiveCMS Engine
// This script runs when the MongoDB container starts for the first time

// Create development database and user
db = db.getSiblingDB('locomotive_engine_dev');

db.createUser({
  user: 'admin',
  pwd: 'password',
  roles: [
    {
      role: 'readWrite',
      db: 'locomotive_engine_dev'
    }
  ]
});

// Create collections for development database
db.createCollection('accounts');
db.createCollection('sites');
db.createCollection('pages');
db.createCollection('content_assets');
db.createCollection('content_entries');
db.createCollection('content_types');
db.createCollection('snippets');
db.createCollection('theme_assets');
db.createCollection('translations');

print('LocomotiveCMS development database initialized successfully');

// Create test database and user
db = db.getSiblingDB('locomotive_engine_test');

db.createUser({
  user: 'admin',
  pwd: 'password',
  roles: [
    {
      role: 'readWrite',
      db: 'locomotive_engine_test'
    }
  ]
});

// Create collections for test database
db.createCollection('accounts');
db.createCollection('sites');
db.createCollection('pages');
db.createCollection('content_assets');
db.createCollection('content_entries');
db.createCollection('content_types');
db.createCollection('snippets');
db.createCollection('theme_assets');
db.createCollection('translations');

print('LocomotiveCMS test database initialized successfully');

// Create a new database for the custom fields
db = db.getSiblingDB('custom_fields_test');

db.createUser({
  user: 'admin',
  pwd: 'password',
  roles: [
    {
      role: 'readWrite',
      db: 'custom_fields_test'
    }
  ]
});