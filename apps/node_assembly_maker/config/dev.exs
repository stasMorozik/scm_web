import Config

config :node_assembly_maker,
  name_node: String.to_atom("node_assembly_maker@debian")

config :mod_logger, 
  name_node: String.to_atom("node_logger@debian"),
  name_process: NodeLogger.Logger
