// Adapted by Rich Morin from https://codepen.io/JoshBlackwood/pen/pEwHe
// Quite flexible about placement of `hs-*` classes (aside from `hs-base`).
// See `.../assets/css/app.css` and `.../templates/layout/_hs_*.html.eex`
// for more information.
//
// Classes:
//
//    hs-base1    1st-level base
//    hs-base2    2nd-level base
//    hs-body1    1st-level body
//    hs-body2    2nd-level body
//    hs-hide1    hide 1st-level item
//    hs-hide2    hide 2nd-level item
//    hs-ih       initially hidden
//    hs-is       initially shown
//    hs-none     don't display now
//    hs-show1    show 1st-level item
//    hs-show2    show 2nd-level item

// Hide or show the extra content initially, using JS.
// (If JS is disabled, the hard-coded classes are used):

$(".hs-ih").addClass(   "hs-none");
$(".hs-is").removeClass("hs-none");

// Hide and show individual items in level 1:

$(".hs-hide1").click( function(e) {
  $(this).addClass("hs-none");
  let base = $(this).closest(".hs-base1");
  base.find(".hs-body1").addClass(   "hs-none");
  base.find(".hs-show1").removeClass("hs-none");
  e.preventDefault();
});

$(".hs-show1").click( function(e) {
  $(this).addClass("hs-none");
  let base = $(this).closest(".hs-base1");
  base.find(".hs-body1, .hs-hide1").removeClass("hs-none");
  e.preventDefault();
});

// Hide and show individual items in level 1:

$(".hs-hide2").click( function(e) {
  $(this).addClass("hs-none");
  let base = $(this).closest(".hs-base2");
  base.find(".hs-body2").addClass(   "hs-none");
  base.find(".hs-show2").removeClass("hs-none");
  e.preventDefault();
});

$(".hs-show2").click( function(e) {
  $(this).addClass("hs-none");
  let base = $(this).closest(".hs-base2");
  base.find(".hs-body2, .hs-hide2").removeClass("hs-none");
  e.preventDefault();
});

// Hide and show every item below this level:

$(".hs-hide-all").click( function(e) {
  $(this).addClass("hs-none");
  let base = $(this).closest("div");
  base.find(".hs-body1, .hs-body2, .hs-hide1, .hs-hide2"
           ).addClass("hs-none");
  base.find(".hs-show1, .hs-show2, .hs-show-all"
           ).removeClass("hs-none");
  e.preventDefault();
});

$(".hs-show-all").click( function(e) {
  $(this).addClass("hs-none");
  let base = $(this).closest("div");
  base.find(".hs-show1, .hs-show2"
           ).addClass(   "hs-none");
  base.find(".hs-body1, .hs-body2, .hs-hide1, .hs-hide2, .hs-hide-all"
           ).removeClass("hs-none");
  e.preventDefault();
});
