defmodule InfoToml.Application do

  use Application

  @doc """
  Load the TOML file tree, then fold in the index.
  """

# @spec - ToDo
# @spec start(atom | tuple, term) :: tuple  # Fails

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    
    children = [
      worker(InfoToml.Server, []),
    ]
    
    options = [
      name:     InfoToml.Supervisor,
      strategy: :one_for_one,
    ]
    
    Supervisor.start_link(children, options)
  end

end
