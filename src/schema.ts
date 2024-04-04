import { makeExecutableSchema } from '@graphql-tools/schema'
import { PubSub } from 'graphql-subscriptions'
import gql from 'graphql-tag'

const pubsub = new PubSub()

const typeDefs = gql`
  type Post {
    title: String!
    content: String!
    createdAt: String!
  }

  type Query {
    getPots: [Post!]!
  }

  type Mutation {
    createPost(title: String!, content: String!): Post!
  }

  type Subscription {
    postCreated: [Post]!
  }
`

interface createPostInput {
  title: string
  content: string
  createdAt: string
}

const postData: createPostInput[] = []

const resolvers = {
  Query: {
    getPots: async () => postData,
  },
  Mutation: {
    createPost: async (_parent: any, args: createPostInput) => {
      const newPost = { ...args, createdAt: new Date().toISOString() }
      postData.push(newPost)
      pubsub.publish(`EVENT_CREATE_POST`, { postCreated: postData })
      return newPost
    },
  },
  Subscription: {
    postCreated: {
      subscribe: async () => pubsub.asyncIterator([`EVENT_CREATE_POST`]),
    },
  },
}

export default makeExecutableSchema({ typeDefs, resolvers })
