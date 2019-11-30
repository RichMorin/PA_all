# _format_test.exs

defmodule PhxHttpWeb.FormatViewTest do

  use ExUnit.Case

  import  PhxHttpWeb.View.Format

  doctest PhxHttpWeb.View.Format

  test "formats a single link as desired" do

    f_authors   = "Rich_Morin"
    output      = fmt_authors(f_authors)

    test_val    = """
    by
    <a href='/item?key=Areas/Catalog/People/Rich_Morin/main.toml'
       title="Go to Rich Morin's page"
      >Rich Morin</a>
    """

    assert output == { :safe, test_val }
  end

  test "formats a pair of links as desired" do

    f_authors   = "Amanda_Lacy, Rich_Morin"
    output      = fmt_authors(f_authors)

    test_val    = """
    by
    <a href='/item?key=Areas/Catalog/People/Amanda_Lacy/main.toml'
       title="Go to Amanda Lacy's page"
      >Amanda Lacy</a>
     and <a href='/item?key=Areas/Catalog/People/Rich_Morin/main.toml'
       title="Go to Rich Morin's page"
      >Rich Morin</a>
    """

    assert output == { :safe, test_val }
  end

  test "formats a file path as desired" do

    test_key  = "Areas/Catalog/Groups/VOISS/main.toml"
    output    = fmt_path(test_key)

    test_out  = """
    <div class="no_print">
      <b>Path:</b>&nbsp;
      <a href="/area"
         title="Go to the Areas index page."
        >Areas</a>,&nbsp;
      <a href="/area?key=Areas/Catalog/_area.toml"
         title="Go to the Areas/Catalog index page."
        >Catalog</a>,&nbsp;
      <a href="/area?key=Areas/Catalog/Groups/_area.toml"
         title="Go to the Areas/Catalog/Groups index page."
        >Groups</a>
    </div>
    """

    assert output == { :safe, test_out }
  end

  test "formats a ref as desired" do

    ref_key = :foo
    ref_val = "cat_peo|Rich_Morin"
    output  = fmt_ref(ref_key, ref_val)
    href    = "/item?key=Areas/Catalog/People/Rich_Morin/main.toml"
    html    = "<b>Foo:</b>&nbsp; <a href='#{ href }' " <>
              "title='Go to: Foo page'>Rich Morin</a>"

    assert output == { :safe, html }
  end

end
