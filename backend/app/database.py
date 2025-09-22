import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

load_dotenv()

class MySQLConnection:
    def __init__(self):
        self.host = os.getenv('MYSQL_HOST', 'localhost')
        self.port = int(os.getenv('MYSQL_PORT', 3306))
        self.user = os.getenv('MYSQL_USER', 'root')
        self.password = os.getenv('MYSQL_PASSWORD', '')
        self.database = os.getenv('MYSQL_DATABASE', 'mysql')
        
    def get_connection(self, database=None):
        try:
            connection = mysql.connector.connect(
                host=self.host,
                port=self.port,
                user=self.user,
                password=self.password,
                database=database or self.database
            )
            return connection
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            return None
    
    def execute_query(self, query, database=None, fetch=True):
        connection = self.get_connection(database)
        if connection:
            try:
                cursor = connection.cursor(dictionary=True)
                cursor.execute(query)
                if fetch:
                    result = cursor.fetchall()
                    return result
                else:
                    connection.commit()
                    return True
            except Error as e:
                print(f"Error executing query: {e}")
                return None
            finally:
                if connection.is_connected():
                    cursor.close()
                    connection.close()
        return None

db = MySQLConnection()