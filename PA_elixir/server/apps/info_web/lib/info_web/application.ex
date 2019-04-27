defmodule InfoWeb.Application do

  use Application

  @doc """
  WIP - Load the link status file.
  """

# @spec - ToDo

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    
    children = [
      worker(InfoWeb.Server, []),
    ]
    
    options = [
      name:     InfoWeb.Supervisor,
      strategy: :one_for_one,
    ]
    
    Supervisor.start_link(children, options)
  end

end
