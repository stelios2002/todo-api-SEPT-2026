# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: "Todo API",
        version: "v1",
        description: "REST API για διαχείριση todos και items με JWT authentication."
      },
      servers: [
        { url: 'http://localhost:3000', description: 'Development server' }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          Item: {
            type: :object,
            properties: {
              id:         { type: :integer, example: 1 },
              content:    { type: :string,  example: 'Αγόρασε γάλα' },
              completed:  { type: :boolean, example: false },
              todo_id:    { type: :integer, example: 1 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id content completed todo_id]
          },
          Todo: {
            type: :object,
            properties: {
              id:          { type: :integer, example: 1 },
              title:       { type: :string,  example: 'Ψώνια' },
              description: { type: :string,  example: 'Για το Σαββατοκύριακο' },
              completed:   { type: :boolean, example: false },
              items_count: { type: :integer, example: 0 },
              items:       { type: :array, items: { '$ref' => '#/components/schemas/Item' } },
              created_at:  { type: :string, format: 'date-time' },
              updated_at:  { type: :string, format: 'date-time' }
            },
            required: %w[id title completed items_count]
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Todo not found' }
            }
          },
          ValidationError: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string },
                example: ["Title can't be blank"]
              }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end