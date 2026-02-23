return function(Table, callback)
  XeninUI.Promises.all({
  XeninUI:InvokeSQL(XeninDB, [[
      CREATE TABLE IF NOT EXISTS xenin_configurator_settings (
        id VARCHAR(127),
        script_id VARCHAR(127),
        value TEXT NOT NULL,
        json BOOLEAN,
        PRIMARY KEY (script_id, id)
      )
    ]], "Xenin.Configurator.Settings")
  }):next(callback)
end
