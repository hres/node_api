
const drugCode = window.location.search.substr(4);
const documentURL = "https://rest-dev.hres.ca/dpd/dpd_json";
const monographURL = "https://rest-dev.hres.ca/rest-dev/product_monographs";
const monographHost = "https://pdf.hres.ca/dpd_pm/";

$(document).ready(() => {

  const url = documentURL + "?select=*&drug_code=eq." + drugCode;

  $.get(url, (data) => {

    const drug = data[0].drug_product;

    $("#product-title").html(drug.brand_name);

    const status = drug.status_detail[0];

    $("#status").html("<strong>" + status.status + "</strong>");

    console.log(drug);

    var statusDate = "N/A";
    var marketDate = "N/A";
    if (status.history_date) statusDate = makeDate(status.history_date);
    if (status.original_market_date) marketDate = makeDate(status.original_market_date);

    $("#status-date").html(statusDate);
    $("#market").html(marketDate);
    $("#product").html(drug.brand_name);
    $("#din").html(drug.drug_identification_number);
		$("#company").html("<strong>" + drug.company.company_name + "</strong>");
    $("#company").append("<br>" + drug.company.street_name + "<br>" + drug.company.city_name + ", " + drug.company.province + "<br>" + drug.company.country + " " + drug.company.postal_code);
    $("#drug-class").html(drug.class);

    if (drug.vet_species) {
			for (var i = 0; i < drug.vet_species.length; i++) {
				if (i == 0) {
					$("#species").html(drug.vet_species[i]);
				}
				else {
					$("#species").append(", " + drug.vet_species[i]);
				}
			}

			$("#species-div").css("display", "block");
		}

    $("#dosage").html(drug.dosage_form[0]);
		$("#route").html(drug.route[0]);
		$("#active").html(drug.number_of_ais);
    if (drug.schedule) $("#schedule").html(drug.schedule[0]);

		if (drug.therapeutic_class) {
			$("#ahfs").html(drug.therapeutic_class[0].tc_ahfs_number + " " + drug.therapeutic_class[0].tc_ahfs);
			$("#atc").html(drug.therapeutic_class[0].tc_atc_number + " " + drug.therapeutic_class[0].tc_atc);
		}

		$("#aig").html(drug.ai_group_no);

    var body = "";

    (drug.active_ingredients_detail).forEach((ing) => {

      body += "<tr>" +
        "<td>" + ing.ingredient + "</td>" +
        "<td>" + ing.strength + " " + ing.strength_unit + "</td>" +
        "</tr>";
    });

    $("#ingredients-content").html(body);
    $("#rmp").html("A Risk Management Plan (RMP) for this product " + (drug.risk_man_plan == "N" ? "was not" : "was") + " submitted.");
    $("#api-call").attr("href", url).attr("target", "_blank").html(url);
    $("#refresh").text(makeDate(drug.last_refresh));
  });

  const url2 = monographURL + "?select=*&drug_code=eq." + drugCode;

  $.get(url2, (data) => {

		if (data.length > 0) {
			var mlink = "https://pdf.hres.ca/dpd_pm/";

			var pm_number = data[0].pm_english_fname
			var pm = 0;

			for (var i = 1; i < data.length; i++) {
				if (data[i].pm_english_fname > pm_number) {
					pm_number = data[i].pm_english_fname;
					pm = i;
				}
			}

			$("#monograph").html("<a href='" + monographHost + maskCode(data[pm].pm_english_fname, 8) + ".PDF" + "' target='_blank'>Electronic Monograph (" + data[pm].pm_date + ")</a>");
		}
		else {
			$("#monograph").html("No Electronic Monograph Available");
		}
	});
});

function maskCode(id, length) {

    var code = "" + id;

    while (code.length < length) code = "0" + code;

    return code;
}

function makeDate(iso) {

  const d = new Date(iso);
  const month = d.getMonth() < 9 ? "0" + (d.getMonth() + 1) : (d.getMonth() + 1);
  const day = d.getDate() < 10 ? "0" + d.getDate() : d.getDate()

  return d.getFullYear() + "-" + month + "-" + day;
}
