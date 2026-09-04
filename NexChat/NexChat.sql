create database NexChat
use  NexChat
CREATE TABLE Users(
phone VARCHAR(30) primary key,
name VARCHAR(100),
password varchar(100),
profile_image VARCHAR(300),
)


CREATE TABLE Chat (
chat_id INT PRIMARY KEY identity(1,1),
sender_id varchar(30),
receiver_id varchar(30),
text TEXT,
message_type VARCHAR(20),
file_url VARCHAR(300),
is_read int DEFAULT 0,
created_at Time,
FOREIGN KEY (sender_id) REFERENCES users(phone),
FOREIGN KEY (receiver_id) REFERENCES users(phone),
)

