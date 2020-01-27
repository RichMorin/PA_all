# phx_http_web/router_toc.ex

defmodule PhxHttpWeb.Router.TOC do
#
# This registration approach taken by this module plug is loosely inspired
# by MinifyResponse.  See https://github.com/gravityblast/minify_response
# for details.
#
# Public Functions
#
#   add_toc/1     add a Table of Contents to the (HTML) output page
#   init/1        required by module plug API (noop)
#   call/2        registers TOC.add_toc/1
#
# Private Functions
#
#   edit_body/2   edit the body of the output page
#   get_name/1    generate a name from a list
#   get_toc/1     generate TOC HTML from the generated accumulator
#   new_acc/3     create an accumulator from the header entries
#   wrap_hdr/2    wrap a header node with a "<a name=...>" node
#   wrap_hdrs/1   wrap all header nodes with "<a name=...>" nodes
#
# Written by Rich Morin, CFCL, 2020.

  @moduledoc """
  The `TOC` plug adds a table of contents to the response body
  when the response content type is text/html.

  ```
  plug PhxHttpWeb.Router.TOC
  ```
  """

  import Common, warn: false, only: [ii: 2]

  alias PhxHttpWeb.Router.TOC

  # Public Functions

  @doc false

# @spec ???

  def add_toc(%Plug.Conn{} = conn) do
  #
  # add a Table of Contents to the (HTML) output pag

    case List.keyfind(conn.resp_headers, "content-type", 0) do
      {_, "text/html" <> _} ->
        body_out  = edit_body(conn)
        %Plug.Conn{conn | resp_body: body_out}

      _ -> conn
    end
  end

  # acc_out should look something like this:
  #
  # [ { 3, [3,1,1], "Target User"    },
  #   { 3, [2,1,1], "Infrastructure" }, 
  #   { 3, [1,1,1], "Accessibility"  }, 
  #   { 2, [1,1],   "Perkify - FAQ"  }, 
  #   { 1, [1],     "Pete's Alley"   } ] 

  @doc false

# @spec ???

  def init(opts \\ []), do: opts
  #
  # required by module plug API (noop)

  @doc false

# @spec ???

  def call %Plug.Conn{} = conn, _ \\ [] do
  #
  # registers TOC.add_toc/1

    Plug.Conn.register_before_send(conn, &TOC.add_toc/1)
  end

  # Private Functions

# @spec ???

  defp edit_body(conn) do
  #
  # edit the body of the output page

    # Parse the input HTML.

    body_inp    = conn.resp_body
    {:ok, tree_inp}   = Floki.parse_document(body_inp)

    # Wrap the headers and accumulate info.

    {tree_out1, acc_out1} = wrap_hdrs(tree_inp)

    # Generate and install the TOC.

    toc_html          = get_toc(acc_out1)
    {:ok, tree_toc}   = Floki.parse_fragment(toc_html)

    tau_fn      = fn
      {"pa_toc", [], []}  ->  hd(tree_toc)

      nodes               ->  nodes
    end

    tree_out2   = tree_out1 |> Floki.traverse_and_update(tau_fn)

    Floki.raw_html(tree_out2)    # Convert tree back into HTML.
  end

# @spec ???

  defp get_name(list) do
  #
  # generate a name from a list

    tmp   = list              # [3,2,1]
    |> Enum.reverse()         # [1,2,3]
    |> Enum.join("x")         # "1x2x3"

    "x#{ tmp }"               # "x1x2x3"
  end

# @spec ???

  defp get_prefix(list) do
  #
  # generate a prefix from a list

    list                      # [5,4,3,2,1]
    |> Enum.reverse()         # [1,2,3,4,5]
    |> Enum.drop(2)           # [3,4,5]
    |> Enum.join(".")         # "3.4.5"
  end

# @spec ???

  defp get_toc(acc_inp) do
  #
  # generate TOC HTML from the generated accumulator
  #
  #   acc_inp: [
  #     {2, [2, 1], "Foo"},
  #     {3, [3, 1, 1], "Target User"},
  #     {3, [2, 1, 1], "Infrastructure"},
  #     {5, [1, 1, 1, 1, 1], "Accessibility"},
  #     {4, [1, 1, 1, 1], ""},
  #     {3, [1, 1, 1], ""},
  #     {2, [1, 1], "Perkify - FAQ"},
  #     {1, [1], "Pete's Alley"}
  #   ]

    filter_fn   = fn {level, _list, _text} -> level > 2 end

    map_fn      = fn {_level, list,  text} ->
      name    = get_name(list)
      prefix  = get_prefix(list)

      line    = if text == "" do
        "?"
      else
        "<a href=\"##{ name }\">#{ text }</a>"
      end

      "  <li>#{ prefix }&nbsp;#{ line }</li>"
    end

    middle  = acc_inp
    |> Enum.reverse()
    |> Enum.filter(filter_fn)
    |> Enum.map(map_fn)
    |> Enum.join("\n")

    """
    <div>
      <b>Contents:</b>
      <ul style="list-style-type:none">
        #{ middle }
      </ul>
    </div>
    """
  end

# @spec ???

  defp new_acc(acc_inp, this_level, nodes) do
  #
  # create an accumulator from the header entries

    this_text    = nodes
    |> Floki.text()
    |> String.trim()

    prev_tuple  = Enum.at(acc_inp, 0) || { 0, [], "" }
    { prev_level, prev_list, _prev_text } = prev_tuple
    level_diff  = this_level - prev_level
    acc_tmp     = acc_inp

    unfold_fn = fn
      ^prev_level -> nil

      tmp_level ->
        foo_cnt   = tmp_level - prev_level
        foo_list  = List.duplicate(1, foo_cnt) ++ prev_list

        t = { tmp_level, foo_list, "" }
        { t, tmp_level-1 }
    end

    { acc_tmp, this_list }  = cond do
      level_diff > 0 ->                           # increased

        { acc_tmp, tmp_list } = case level_diff do
          1 ->
            { acc_tmp, prev_list }

          _ ->
            add_list  = Stream.unfold(this_level-1, unfold_fn)
            |> Enum.to_list()

            acc_tmp     = add_list ++ acc_tmp
            { acc_tmp, prev_list }
        end

        tmp_list = [ 1 | tmp_list ]               # [2,1] -> [1,2,1]
        { acc_tmp, tmp_list }

      level_diff < 0 ->                           # decreased
        tmp_list    = Enum.drop(prev_list, -level_diff)
        this_index  = hd(tmp_list) + 1
        tmp_list = [ this_index | tl(tmp_list) ]  # [2,1] -> [3,1]
        { acc_tmp, tmp_list }

      true  ->                                    # unchanged
        this_index  = hd(prev_list) + 1
        tmp_list = [ this_index | tl(prev_list) ]
        { acc_tmp, tmp_list }
    end

    item_out  = cond do
      Enum.empty?(acc_tmp) ->
        { this_level, [ 1 ], this_text }

      level_diff <= 0 ->
        { this_level, this_list, this_text }

      true ->
        bar_list  = acc_tmp   # [ {4, [1, 1, 1, 1], ""}, ... ]
        |> hd()               # {4, [1, 1, 1, 1], ""}
        |> elem(1)            # [1, 1, 1, 1]

        { this_level, [ 1 | bar_list ], this_text }
    end

    [ item_out | acc_tmp ]                        # [2,1] -> [3,1]
  end

# @spec ???

  defp wrap_hdr(acc_out, node_inp) do
  #
  # wrap a header node with a "<a name=...>" node

    { _level, list, _text } = hd(acc_out)
    { "a", [ {"name", get_name(list)} ], node_inp }
  end

# @spec ???

  defp wrap_hdrs(tree_inp) do
  #
  # wrap all header nodes with "<a name=...>" nodes

    tau_fn1 = fn level, tuple, acc_inp ->
      acc_out   = new_acc(acc_inp, level, tuple)
      node_out  = wrap_hdr(acc_out, tuple)
      { node_out, acc_out }
    end

    tau_fn2 = fn
      tuple = {"h1", _, _}, acc -> tau_fn1.(1, tuple, acc)
      tuple = {"h2", _, _}, acc -> tau_fn1.(2, tuple, acc)
      tuple = {"h3", _, _}, acc -> tau_fn1.(3, tuple, acc)
      tuple = {"h4", _, _}, acc -> tau_fn1.(4, tuple, acc)
      tuple = {"h5", _, _}, acc -> tau_fn1.(5, tuple, acc)
      tuple = {"h6", _, _}, acc -> tau_fn1.(6, tuple, acc)

      nodes, acc        -> {nodes, acc}
    end

    {tree_out, acc_out}  = tree_inp
    |> Floki.traverse_and_update([], tau_fn2)

    {tree_out, acc_out}
  end

end