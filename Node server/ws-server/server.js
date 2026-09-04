const WebSocket = require("ws");
const url = require("url");

const server = new WebSocket.Server({ port: 5500 });
const users = new Map();

server.on("connection", (socket, req) => {
  const query = url.parse(req.url, true).query;
  const user_id = query.user_id;

  users.set(user_id, socket);
  console.log("User connected:", user_id);

  socket.on("message", (data) => {
    try {
      const message = JSON.parse(data.toString());
      const { receiver_id, message_type, text, file_url,created_at,otherFiles,is_read,orignalFileName } = message;
      
      const receiver = users.get(receiver_id);            

      if (receiver && receiver.readyState === WebSocket.OPEN) {
        receiver.send(JSON.stringify({
          sender_id: user_id,
          message_type: message_type,
          text: text ,
          file_url: file_url,
          created_at: created_at,
          is_read:is_read,
          otherFiles:otherFiles,
          orignalFileName:orignalFileName
        }));
      } else {
        console.log("Offline:", receiver_id);
      }
    } catch (err) {
      console.log("Invalid JSON", err.message);
    }
  });

  socket.on("close", () => {
    users.delete(user_id);
    console.log("User disconnected:", user_id);
  });
});

//-----------------STATUS SERVER-------------------

const statusWS=require("ws");
const statusServer=new statusWS.Server({port:5600});
const statusUsers=new Map();

statusServer.on("connection",(socket,req)=>{
  const query=url.parse(req.url,true).query
  const user_id=query.user_id;

  statusUsers.set(user_id,socket);
  const interval = setInterval(() => {
    statusUsers.forEach((client, id) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(
          JSON.stringify({
            status: "online",
            user_id: user_id,
          })
        );
      }
    });
  }, 5000);


    socket.on("close", () => { 
    clearInterval(interval)           
    statusUsers.forEach((client,id) => {
    if(id!=user_id && client.readyState===WebSocket.OPEN)
    {
      client.send(JSON.stringify({
        status:"offline",
        user_id : user_id
      }))      
    }
    statusUsers.delete(user_id)
    console.log("User disconnected:", user_id)
    })
    
  });
});
