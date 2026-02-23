return function(Table)
  Table("xenin_framework_settings", function(tbl)
    tbl:string("id", 191):primary()
    tbl:text("value")
    tbl:boolean("json"):nullable()
    tbl:integer("server_id"):nullable()
  end)
end
