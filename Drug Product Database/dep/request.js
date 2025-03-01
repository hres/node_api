
const search = window.location.search.substr(1);
const documentURL = "https://rest-dev.hres.ca/dpd/dpd_search";
const limit = 25;
const pagesAllowed = 5;
var page = 0;

$(document).ready(() => {

  var q;
  var queries = search.split("&");
  var queryObj = {};

  queries.forEach((query) => {

    if (query.indexOf("=") > -1) {
      var qc = query.split("=");
      queryObj[qc[0]] = decodeURIComponent(qc[1]);
    }
  });

  if (queryObj.hasOwnProperty("q")) q = (queryObj.q).split(" ");
  if (queryObj.hasOwnProperty("page") && !isNaN(queryObj.page)) page = parseInt(queryObj.page) - 1;

  q.forEach((_q) => {

    if (_q.indexOf("(") > -1 || _q.indexOf(")") > -1) q.splice(q.indexOf(_q), 1);
  });

  $("#terms").text(q.join(" "));

  if (q) {
    requestDocuments(q);
  }
  else {
    end();
  }
});

function requestDocuments(q) {

  var url = documentURL + "?select=drug_product";

  q.forEach((_q) => {

    url += ("&search=fts." + _q);
  });

  url += "&order=drug_product->>brand_name";

  const range = (page * limit) + "-" + (((page + 1) * limit) - 1);

  $.ajax({
		url: url,
		method: "GET",
		beforeSend: (xhr) => {

			xhr.setRequestHeader('Range-Unit', 'items');
			xhr.setRequestHeader('Range', range);
			xhr.setRequestHeader('Prefer', 'count=exact');
		},
		success: (data, status, xhr) => {

			var content = xhr.getResponseHeader('Content-Range');
      populateTable(data);
      createPagination(content);
		},
    error: (err) => {

      end();
    }
	});
}

function populateTable(data) {

  console.log(data);

  var body = "";

  const drugPageURL = document.documentElement.lang == "fr" ? "drug-fr.html" : "drug.html";

  data.forEach((d) => {

    const drug = d.drug_product;

    var status = document.documentElement.lang == "fr" ? drug.status_current_f : drug.status_current;
    var drugClass = document.documentElement.lang == "fr" ? drug.class_f : drug.class;

    var ingredients = $.map(drug.active_ingredients_detail, (ing) => {

      return (document.documentElement.lang == "fr") ? (ing.ingredient_f + " (" + ing.strength + " " + ing.strength_unit_f + ")") : (ing.ingredient + " (" + ing.strength + " " + ing.strength_unit + ")");
    }).join(", ");

    body += "<tr>" +
      "<td>" + status + "</td>" +
      "<td><a href='" + drugPageURL + "?pr=" + drug.drug_code + "'>" + drug.drug_identification_number + "</a></td>" +
      "<td>" + drug.company.company_name + "</td>" +
      "<td>" + drug.brand_name + "</td>" +
      "<td>" + drugClass + "</td>" +
      "<td>" + ingredients + "</td>" +
      "</tr>";
  });

  $("#drug-table").attr("hidden", false);
  $("#table-content").html(body);
  $("#pagination").attr("hidden", false);
  $("#empty").attr("hidden", true);
  $("#refresh").text(makeDate(data[0].drug_product.last_refresh));
}

function createPagination(content) {

  var range = (content.split("/"))[0];
  var start = parseInt((range.split("-"))[0]) + 1;
  var end = parseInt((range.split("-"))[1]) + 1;
  var total = (content.split("/"))[1];

  $("#count").text("(Displaying results " + start + " - " + end + " of " + total + ")");

  const totalPages = Math.ceil(total / limit);
  const pageMedian = Math.ceil(pagesAllowed / 2);
  const pageDeviation = Math.floor(pagesAllowed / 2);

  var currentPage = page + 1;
  var pageArray = [];

  if (currentPage < pageMedian) {
    for (var i = 0; i < pagesAllowed; i++) {
      if (i < totalPages) pageArray.push(i + 1);
    }

    makePages(pageArray, currentPage);
  }
  else if (currentPage + pageDeviation > totalPages) {
    for (var i = 0; i < pagesAllowed; i++) pageArray.unshift(totalPages - i);

    makePages(pageArray, currentPage);
  }
  else {
    for (var i = 0; i < pagesAllowed; i++) pageArray.push((currentPage - pageDeviation) + i);

    makePages(pageArray, currentPage);
  }
}

function makePages(pageArray, current) {

  for (var i = 0; i < pagesAllowed; i++) {
    if (i < pageArray.length) {
      var btn = "btn-default";

      if (pageArray[i] == current) {
        btn = "btn-primary";
      }

      $("#pg-" + i).addClass(btn).html(pageArray[i]).attr("onclick", "travel(" + pageArray[i] + ")");
    }
    else {
      $("#pg-" + i).css("display", "none");
    }
  }
}

function travel(page) {

  var searchComponents = search.split("&");
  var q;

  searchComponents.forEach((c) => {

    if (c.startsWith("q=")) q = c;
  });

  window.location.href = "results.html?" + q + "&page=" + page;
}

function end() {

  $("#drug-table").attr("hidden", true);
  $("#pagination").attr("hidden", true);
  $("#empty").attr("hidden", false);
}

function makeDate(iso) {

  const d = new Date(iso);
  const month = d.getMonth() < 9 ? "0" + (d.getMonth() + 1) : (d.getMonth() + 1);
  const day = d.getDate() < 10 ? "0" + d.getDate() : d.getDate()

  return d.getFullYear() + "-" + month + "-" + day;
}
