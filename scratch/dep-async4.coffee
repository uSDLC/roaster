module.exports = (exchange) ->
  exchange.respond.client -> (error, next) ->
    async = -> next null, 'dep-async-4 result'
    setTimeout async, 200
