# _info_web_t.ex

defmodule InfoWeb.Types do

  @moduledoc """
  This module defines types for use in `InfoWeb`.
  It doesn't contain any functions, just attributes.
  """

  # result_map, et al

  @typedoc """
  `bins_map` contains information on HTML links, binned by status:

      %{
        <status>: [ { note, from_path, page_url }, ... ]
      }
  """
  @type bins_map :: %{ atom => [link_out] }


  @typedoc """
  The `link_out` tuple contains output information on an HTML link:

      { note, from_path, page_url }
  """
  @type link_out :: {st, st, st}


  @typedoc """
  The `link_work` tuple contains working information on an HTML link:

      { status, note, from_path, page_url }
  """
  @type link_work :: {atom, st, st, st}


  @typedoc """
  The `ok_map` contains URLs that are forced or known to be OK.

      %{ <url> => true, ... ]
  """
  @type ok_map :: %{ st => true }


  @typedoc """
  The `result_map` contains output information on HTML links:

      %{
        bins:     %{
          <status>: [ { note, from_path, page_url }, ... ]
        }
        forced:   [ <url>, ... ]
      }
  """
  @type result_map ::
    %{
      bins:     bins_map,
      forced:   ok_map
    }


  @typedoc """
  The `snap_map` contains snapshot information on HTML links:

      %{
        bins: %{
          ext_ng:   [ [ "<url>", "<from>", "<status>" ], ... ],
          int_ng:   [ [ "<url>", "<from>", "<status>" ], ... ]
        },
        counts; %{
          ext:      %{ "<site>"  => <count>, ... },
          int:      %{ "<route>" => <count>, ... }
        },
        forced: %{
          "<url>" => true
        },
        raw: %{
          ext_ok:   [ "<url>", ... ]
        }
      }
  """
  @type snap_map ::
    %{
      :bins               => %{ atom => [ {st, st, st} ] },
      optional(:counts)   => %{ st => nni  },
      :forced             => %{ st => true },
      optional(:raw)      => %{ st => [st] },
    }

  # Private types

  @typep nni      :: non_neg_integer
  @typep st       :: String.t

end
