defmodule InfoWeb.Common do
#
# Public functions
#
#   validate_uri/1
#     Make sure a URI has all the requisite fields.

  @moduledoc """
  This module contains general purpose functions and macros for use in InfoWeb.
  """

  use InfoWeb.Types

  @doc """
  Make sure a URI has all the requisite fields.
  """

# @spec - WIP

  def validate_uri(uri_str) do
  #
  # Adapted from https://stackoverflow.com/questions/30696761

    uri   = URI.parse(uri_str)

    case uri do
      %URI{scheme:  nil}  -> {:error, uri}
      %URI{host:    nil}  -> {:error, uri}
      %URI{path:    nil}  -> {:error, uri}
      uri                 -> {:ok, uri}
    end 
  end 

end
