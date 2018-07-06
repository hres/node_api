
const drugCode = window.location.search.substr(4);
const documentURL = "https://rest-dev.hres.ca/rest-dev/dpd_json";
const monographURL = "https://rest-dev.hres.ca/rest-dev/product_monographs";
const monographHost = "https://pdf.hres.ca/dpd_pm/";

$(document).ready(() => {

  const url = documentURL + "?select=*&drug_code=eq." + drugCode;

  $.get(url, (data) => {

    const drug = data[0].drug_product;

    $("#product-title").html(drug.brand_name);
    var marketDate = "N/A";

    (drug.status).forEach((s) => {

      if (s.current_status_flag == "Y") {
        $("#status").html("<strong>" + s.status + "</strong>");
        $("#status-date").html(s.history_date);
      }

      if (s.status == "MARKETED") {
        if (s.history_date < marketDate) marketDate = s.history_date;
      }
    });

    $("#market").html(marketDate);
    $("#product").html(drug.brand_name);
    $("#din").html(drug.drug_identification_number);
		$("#company").html("<strong>" + drug.company.company_name + "</strong>");
		if (drug.company.suite_number !== "") $("#company").append("<br>" + drug.company.suite_number);
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

    (drug.active_ingredients).forEach((ing) => {

      body += "<tr>" +
        "<td>" + ing.ingredient + "</td>" +
        "<td>" + ing.strength + " " + ing.strength_unit + "</td>" +
        "</tr>";
    });

    $("#ingredients-content").html(body);
    $("#api-call").attr("href", url).attr("target", "_blank").html(url);
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
