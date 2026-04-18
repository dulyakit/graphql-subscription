import express from 'express'
import { createServer } from 'http'
import { WebSocketServer } from 'ws'
import { useServer } from 'graphql-ws/lib/use/ws'
import { ApolloServer } from '@apollo/server' // ยังคงใช้ @apollo/server สำหรับ ApolloServer
import { expressMiddleware } from '@as-integrations/express4' // เปลี่ยนไปใช้แพ็กเกจการรวมแยกต่างหาก
import cors from 'cors'
import bodyParser from 'body-parser'
import schema from './schema'

const initApollo = async () => {
  const app = express()
  const httpServer = createServer(app)

  const wsServer = new WebSocketServer({
    server: httpServer,
    path: '/graphql',
  })

  useServer({ schema }, wsServer)

  const server = new ApolloServer({ schema })

  await server.start()

  app.use(
    '/graphql',
    cors<cors.CorsRequest>(),
    bodyParser.json(),
    expressMiddleware(server)
  )

  httpServer.listen(4000, () => {
    console.log(`🚀 Server ready at http://localhost:4000/graphql`)
  })
}

initApollo()
