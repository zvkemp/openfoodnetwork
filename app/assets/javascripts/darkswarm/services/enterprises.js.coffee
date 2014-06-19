Darkswarm.factory 'Enterprises', (enterprises)->
  new class Enterprises
    enterprises_by_id: {} # id/object pairs for lookup 
    constructor: ->
      @enterprises = enterprises
      for enterprise in enterprises
        @enterprises_by_id[enterprise.id] = enterprise
      @dereference()
    
    dereference: ->
      for enterprise in @enterprises
        if enterprise.hubs
          for hub, i in enterprise.hubs
            enterprise.hubs[i] = @enterprises_by_id[hub.id]

        if enterprise.producers
          for producer, i in enterprise.producers
            enterprise.producers[i] = @enterprises_by_id[producer.id]
