return function(Table)
  return XeninUI.Promises.all({
    Table("xenin_framework_players", function(tbl)
      tbl:steamid64("id")
      tbl:timestamp("created_at")

      tbl:constraint():primary("id")
    end),
    Table("xenin_framework_players_history", function(tbl)
      tbl:increments("id")
      tbl:steamid64("player_id")
      tbl:timestamp("joined_at"):default("CURRENT_TIMESTAMP")
      tbl:timestamp("left_at"):nullable():default("NULL")

      tbl:constraint():foreign("player_id"):references("xenin_framework_players"):columns("id"):cascade()
    end),
    Table("xenin_framework_notifications", function(tbl)
      tbl:increments("id")
      tbl:string("script_id", 128)
      tbl:string("type", 64)
      tbl:steamid64("target_id")
      tbl:text("content")
      tbl:timestamp("created_at"):default("CURRENT_TIMESTAMP")
      tbl:timestamp("read_at"):nullable():default("NULL")
      tbl:text("data"):nullable()

      tbl:constraint():unique("id", "script_id")

      tbl:constraint():foreign("target_id"):references("xenin_framework_players"):columns("id"):cascade()
    end)
  })
end
