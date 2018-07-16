
"use strict";

const autocompleteURL = "https://rest-dev.hres.ca/dpd/dpd_lookup";
const autocompleteLimit = 20;
const resultPageURL = "results.html";
const illegal = ["of", "&", "and", "?", "!", "or", "+", "-", "no."];

$(document).ready(() => {
  new autoComplete({
    selector: "#search",
    minChars: 2,
    source: (term, suggest) => {
      term = term.toLowerCase();

      $.get(getTermQuery(term), (data) => {

        var keywords = $.map(data, (obj) => {

          return [obj.ingredient + " (ingredient)", obj.company_name + " (company)", obj.brand_name + " (brand)"];
        });

        var suggestions = [];

        keywords.forEach((keyword) => {
          if (keyword.toLowerCase().indexOf(term) > -1) {
            const pushKeyword = keyword.toLowerCase()
            if (!suggestions.includes(pushKeyword)) suggestions.push(pushKeyword);
          }
        });

        suggest(suggestions);
      });
    }
  })
});

function getTermQuery(term) {

  return autocompleteURL + "?or=(or(brand_name.ilike." + term + "*,company_name.ilike." + term + "*),ingredient.ilike." + term + "*)&limit=" + autocompleteLimit;
}

function passRequest() {

  var string = $("#search").val();
  var search = string.split(" ");

  illegal.forEach((def) => {

    const i = $.inArray(def, search);

    if (i > -1) search.splice(i, 1);
  });

  if (search.length > 0) {
    window.location.href = resultPageURL + "?q=" + search.join("%20");
  }
}
