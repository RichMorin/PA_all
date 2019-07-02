# info_web/common.ex

defmodule InfoWeb.Common do
#
# Public functions
#
#   validate_uri/1
#     Make sure a URI has all the requisite fields.

  @moduledoc """
  This module contains general purpose functions and macros for use in InfoWeb.
  """

  # Public functions

  @doc """
  Make sure a URI has all the requisite fields.

      iex> validate_uri("http://cfcl.com")
      {  :error,
         %URI{
           authority:   "cfcl.com",
           fragment:    nil,
           host:        "cfcl.com",
           path:        nil,
           port:        80,
           query:       nil,
           scheme:      "http",
           userinfo:    nil
      } }

      iex> validate_uri("http://cfcl.com/")
      {  :ok,
         %URI{
           authority:   "cfcl.com",
           fragment:    nil,
           host:        "cfcl.com",
           path:        "/",
           port:        80,
           query:       nil,
           scheme:      "http",
           userinfo:    nil
      } }
  """

  @spec validate_uri(String.t) :: {atom, map}

  def validate_uri(uri_str) do
  #
  # Adapted from https://stackoverflow.com/questions/30696761

    uri   = URI.parse(uri_str)

    case uri do
      %URI{scheme:  nil}  -> {:error, uri}
      %URI{host:    nil}  -> {:error, uri}
      %URI{path:    nil}  -> {:error, uri}
      uri                 -> {:ok,    uri}
    end 
  end 

end
