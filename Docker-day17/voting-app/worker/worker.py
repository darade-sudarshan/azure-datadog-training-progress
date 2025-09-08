import redis
import psycopg2
import json
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_redis_connection():
    return redis.Redis(host='redis', port=6379, db=0)

def get_db_connection():
    return psycopg2.connect(
        host='db',
        database='votes',
        user='postgres',
        password='postgres'
    )

def create_table():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS votes (
            id SERIAL PRIMARY KEY,
            voter_id VARCHAR(255) NOT NULL,
            vote VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    cur.close()
    conn.close()

def process_votes():
    redis_conn = get_redis_connection()
    
    while True:
        try:
            # Get vote from Redis queue
            vote_data = redis_conn.blpop('votes', timeout=5)
            
            if vote_data:
                vote_json = vote_data[1].decode('utf-8')
                vote_info = json.loads(vote_json)
                
                # Store in PostgreSQL
                conn = get_db_connection()
                cur = conn.cursor()
                cur.execute(
                    "INSERT INTO votes (voter_id, vote) VALUES (%s, %s)",
                    (vote_info['voter_id'], vote_info['vote'])
                )
                conn.commit()
                cur.close()
                conn.close()
                
                logger.info(f"Processed vote: {vote_info['vote']} from {vote_info['voter_id']}")
            
        except Exception as e:
            logger.error(f"Error processing vote: {e}")
            time.sleep(1)

if __name__ == '__main__':
    logger.info("Starting worker...")
    
    # Wait for services to be ready
    time.sleep(10)
    
    # Create table if not exists
    create_table()
    
    # Start processing votes
    process_votes()