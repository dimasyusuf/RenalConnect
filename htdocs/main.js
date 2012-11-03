tt = function(root,active,total) {
	for (var i=0; i<=total; i++) {
		document.getElementById(root+i).className = "tab tabOff b";
	}
	document.getElementById(root+active).className = "tab tabAct b";
	clear_date_picker();
}
ajax = function(t_div,s_div) {
	var t_obj;
	var s_obj;
	if (parent.document.getElementById(t_div)) {
		t_obj = parent.document.getElementById(t_div);
	}
	if (document.getElementById(s_div)) {
		s_obj = document.getElementById(s_div);
	}
	if (t_obj && s_obj) {
		t_obj.innerHTML = s_obj.innerHTML;
	} else {
		document.body.innerHTML = "";
		// alert("Error: target or source not found.");
	}
}
ajax_page = function(t_div,s_div) {
	var t_obj;
	var s_obj;
	if (parent.document.getElementById(t_div)) {
		t_obj = parent.document.getElementById(t_div);
	}
	if (document.getElementById(s_div)) {
		s_obj = document.getElementById(s_div);
	}
	if (t_obj && s_obj) {
		t_obj.innerHTML = s_obj.innerHTML;
	} else {
		document.body.innerHTML = "";
		// alert("Error: target or source not found.");
	}
}
ajax_input = function(t_div,s_div) {
	var t_obj;
	var s_obj;
	if (parent.document.getElementById(t_div)) {
		t_obj = parent.document.getElementById(t_div);
	}
	if (document.getElementById(s_div)) {
		s_obj = document.getElementById(s_div);
	}
	if (t_obj && s_obj) {
		t_obj.value = s_obj.innerHTML;
	} else {
		// document.body.innerHTML = "";
		// alert("Error: target or source not found.");
	}
}
ajax_pop_up = function(t_div,s_div) {
	var t_obj;
	var s_obj;
	if (parent.document.getElementById(t_div)) {
		t_obj = parent.document.getElementById(t_div);
	}
	if (document.getElementById(s_div)) {
		s_obj = document.getElementById(s_div);
	}
	if (t_obj && s_obj) {
		pop_up_show();
		t_obj.innerHTML = s_obj.innerHTML;
	} else {
		document.body.innerHTML = "";
		// alert("Error: target or source not found.");
	}
}
pop_up_show = function() {
	var p_obj;
	var c_obj;
	if (document.getElementById("div_pop_up_bg")) {
		p_obj = document.getElementById("div_pop_up_bg");
		c_obj = document.getElementById("div_pop_up_container");
	} else {
		p_obj = parent.document.getElementById("div_pop_up_bg");
		c_obj = parent.document.getElementById("div_pop_up_container");
	}
	var t_h = getElementHeight("div_all");
	p_obj.style.height = t_h+"px";
	p_obj.className = "show";
	var bg_w = getElementWidth("div_pop_up_bg");
	c_obj.style.left = Math.round(bg_w/2-410)+"px";
}
pop_up_hide = function() {
	var p_obj;
	if (document.getElementById("div_pop_up_bg")) {
		p_obj = document.getElementById("div_pop_up_bg");
	} else {
		p_obj = parent.document.getElementById("div_pop_up_bg");
	}
	p_obj.className = "hide";
}
pop_up_resize = function() {
	var p_obj;
	var c_obj;
	if (document.getElementById("div_pop_up_bg")) {
		p_obj = document.getElementById("div_pop_up_bg");
		c_obj = document.getElementById("div_pop_up_container");
	} else {
		p_obj = parent.document.getElementById("div_pop_up_bg");
		c_obj = parent.document.getElementById("div_pop_up_container");
	}
	var bg_w = getElementWidth("div_pop_up_bg");
	c_obj.style.left = Math.round(bg_w/2-410)+"px";
}
function getElementHeight(t_obj) {
	if (document.getElementById(t_obj)) {
		return document.getElementById(t_obj).offsetHeight;
	} else {
		return parent.document.getElementById(t_obj).offsetHeight;
	}
}
function getElementWidth(t_obj) {
	if (document.getElementById(t_obj)) {
		return document.getElementById(t_obj).offsetWidth;
	} else {
		return parent.document.getElementById(t_obj).offsetWidth;
	}
}
function get_selected_value(drop_down) {
	var value_string = document.getElementById(drop_down).options[document.getElementById(drop_down).selectedIndex].value;
	return value_string;
}
function set_selected_index(drop_down, change_to) {
	var s = document.getElementById(drop_down);
    for (var i = 0; i < s.options.length; i++) {
        if (s.options[i].value == change_to) {
            s.options[i].selected = true;
            return;
        }
    }
}
function set_antibiotics_preset(antibiotic, dose, dose_loading, dose_rounding, dose_per_kg, dose_units, freq, route, dose_duration, freq_capd) {
	dose = parseFloat(dose);
	dose_loading = parseFloat(dose_loading);
	dose_rounding = parseFloat(dose_rounding);
	if (dose_per_kg == "yes") {
		var weight = parseFloat(document.getElementById("form_abx_weight").innerHTML);
		dose_loading = dose_loading * weight;
		dose = dose * weight;
		var dose_loading_rounding_amount = dose_rounding;
		var dose_rounding_amount = dose_rounding;
		while (dose_loading_rounding_amount < dose_loading) {
			dose_loading_rounding_amount = dose_loading_rounding_amount + dose_rounding;
		}
		while (dose_rounding_amount < dose) {
			dose_rounding_amount = dose_rounding_amount + dose_rounding;
		}
		dose_loading = dose_loading_rounding_amount;
		dose = dose_rounding_amount;
	}
	set_selected_index("form_abx_dose_amount_units", dose_units);
	document.getElementById("form_abx_dose_label").innerHTML = dose_units;
	var is_capd = document.getElementById("is_capd").innerHTML;
	if ((is_capd == "1") && (freq_capd != "")) {
		set_selected_index("form_abx_dose_frequency", freq_capd);
	} else {
		set_selected_index("form_abx_dose_frequency", freq);
	}
	set_selected_index("form_abx_route", route);
	if (document.getElementById("loading_dose_" + antibiotic).innerHTML == "0") {}
	document.getElementById("form_abx_dose_amount_loading").value = dose_loading;
	document.getElementById("form_abx_dose_amount").value = dose;
	set_selected_index("form_abx_regimen_duration", dose_duration);
}
function set_dose_units() {
	var dose = get_selected_value("form_abx_dose_amount_units");
	document.getElementById("form_abx_dose_label").innerHTML = dose;
}
function set_duration() {
	var duration = get_selected_value("form_abx_regimen_duration");
	var token = document.getElementById("form_abx_regimen_token").innerHTML;
	var start = document.getElementById("form_abx_date_start").value;
	var ref = document.getElementById("form_abx_regimen_ref").innerHTML;
	var url = "ajax.pl?token="+token+"&ref="+ref+"&do=set_duration&start="+start+"&duration="+duration;
	document.getElementById("hbin").src = url;
}
function set_hospitalization() {
	var hos = get_selected_value("form_case_hospitalization_required");
	var hdv = document.getElementById("form_case_hospitalization_info_div");
	var sd = document.getElementById("form_case_hospitalization_start_date");
	var sdd = document.getElementById("form_case_hospitalization_start_date_default");
	if (hos == "Yes") {
		hdv.className = "show";
		if (sd.value == "") {
			sd.value = sdd.innerHTML;
		}
	} else {
		hdv.className = "hide";
		if (sd.value == sdd.innerHTML) {
			sd.value = "";
		}
	}
}
function set_pathogens(number) {
	var pat = get_selected_value("form_labs_pathogen_"+number);
	var odv = document.getElementById("form_labs_pathogen_"+number+"_other_div");
	var oan = document.getElementById("form_labs_pathogen_"+number+"_other");
	if (pat == "Final: Other") {
		odv.className = "show";
	} else {
		odv.className = "hide";
		oan.value = "";
	}
}
function set_antibiotics() {
	var abx = get_selected_value("form_abx_antibiotic");
	var odv = document.getElementById("form_abx_antibiotic_other_div");
	var oan = document.getElementById("form_abx_antibiotic_other");
	if (abx == "Other") {
		odv.className = "show";
	} else {
		oan.value = "";
		odv.className = "hide";
		if (abx == "Ampicillin") {
			set_antibiotics_preset("Ampicillin", "2", "2", "500", "no", "g", "QD", "IP", "14", "");
		} else if (abx == "Cefazolin") {
			set_antibiotics_preset("Cefazolin", "20", "20", "500", "yes", "mg", "QD", "IP", "14", "");
		} else if (abx == "Ceftazidime") {
			set_antibiotics_preset("Ceftazidime", "2", "2", "500", "no", "g", "QD", "IP", "14", "");
		} else if (abx == "Ceftriaxone") {
			set_antibiotics_preset("Ceftriaxone", "1", "1", "1", "no", "g", "QD", "PO", "14", "");
		} else if (abx == "Ciprofloxacin") {
			set_antibiotics_preset("Ciprofloxacin", "500", "500", "250", "no", "mg", "QD", "PO", "14", "");
		} else if (abx == "Fluconazole") {
			set_antibiotics_preset("Fluconazole", "100", "100", "100", "no", "mg", "Q2D", "PO", "14", "");
		} else if (abx == "Gentamicin") {
			set_antibiotics_preset("Gentamicin", "0.5", "1.5", "10", "yes", "mg", "QD", "IP", "14", "");
		} else if (abx == "Meropenem") {
			set_antibiotics_preset("Meropenem", "500", "500", "500", "no", "mg", "QD", "IP", "14", "");
		} else if (abx == "Mycafungin") {
			set_antibiotics_preset("Mycafungin", "100", "100", "100", "no", "mg", "QD", "IV", "14", "");
		} else if (abx == "Rifampin") {
			set_antibiotics_preset("Rifampin", "600", "600", "600", "no", "mg", "QD", "PO", "14", "");
		} else if (abx == "Tobramycin") {
			set_antibiotics_preset("Tobramycin", "0.5", "1.5", "10", "yes", "mg", "QD", "IP", "14", "");
		} else if (abx == "Trimethoprim Sulfamethoxazole") {
			set_antibiotics_preset("Trimethoprim Sulfamethoxazole", "160", "160", "160", "no", "mg", "QD", "PO", "14", "");
		} else if (abx == "Vancomycin") {
			set_antibiotics_preset("Vancomycin", "15", "30", "500", "yes", "mg", "Q3D", "IP", "14", "Q5D");
		}
	}
	set_duration();
}
window.onresize = function (){
	var p_obj = document.getElementById("div_pop_up_bg");
	var t_h = getElementHeight("div_all");
	p_obj.style.height = t_h+"px";
}
function getY(oElement) {
	var iReturnValue = 0;
	while( oElement != null ) {
		iReturnValue += oElement.offsetTop;
		oElement = oElement.offsetParent;
	}
	return iReturnValue;
}
function getX(oElement) {
	var iReturnValue = 0;
	while( oElement != null ) {
		iReturnValue += oElement.offsetLeft;
		oElement = oElement.offsetParent;
	}
	return iReturnValue;
}
move_to = function(sourceObj,destObj) {
	var source = document.getElementById(sourceObj);
	var dest = document.getElementById(destObj);
	if (source && dest) {
		var move_to_x = getX(dest) + 130;
		var move_to_y = getY(dest) - 30;
		source.style.top = move_to_y + 'px';
		source.style.left = move_to_x + 'px';
	}
}
show_def = function() {
	move_to("def","form_case_case_type");
	document.getElementById("def").className = "show";
}
hide_def = function() {
	document.getElementById("def").className = "hide";
}
init_new_case_ajax = function() {
	document.getElementById("new_case_no_ajax").className = "hide";
	document.getElementById("new_case_ajax").className = "show";
}
refresh_new_case_ajax = function(search_value_string) {
	var token = document.getElementById("form_case_patient_selector_token").innerHTML;
	var prev = document.getElementById("form_case_patient_selector_prev").innerHTML;
	var ref = document.getElementById("form_case_patient_selector_ref").innerHTML;
	if (search_value_string == "" || search_value_string.length < 2) {
		document.getElementById("form_case_patient_selector").innerHTML = "";
	} else {
		if (prev != search_value_string) {
			document.getElementById("form_case_patient_selector").innerHTML = document.getElementById("form_case_patient_selector_searching").innerHTML;
			var url = "ajax.pl?token="+token+"&ref="+ref+"&do=add_case_select_patient&add_case_select_patient_query="+search_value_string;
			document.getElementById("hbin").src = url;
		}
		document.getElementById("form_case_patient_selector_prev").innerHTML = search_value_string;
	}
}
dismiss_provide_reason = function(alert_id) {
	document.getElementById("alert_dismiss_box_"+alert_id).className = "hide";
	document.getElementById("alert_dismiss_reason_box_"+alert_id).className = "show";
	document.getElementById("sbin").src = "/images/blank.gif";
}
cancel_dismiss = function(alert_id) {
	document.getElementById("alert_dismiss_box_"+alert_id).className = "show";
	document.getElementById("alert_dismiss_reason_box_"+alert_id).className = "hide";
	document.getElementById("sbin").src = "/cgi-bin/alerts.pl";
}
refresh_new_case_js = function(search_value_string) {
	var total_blocks = document.getElementById("ncpt").value;
	if (search_value_string == "" || search_value_string.length < 2) {
		for (var i = 0; i < total_blocks; i++) {
			if (document.getElementById("ncp_"+i)) {
				document.getElementById("ncp_"+i).className = "float-l w25p hide";
			}
		}
	} else {
		search_value_string = search_value_string.toLowerCase();
		search_value_string = search_value_string.replace(/\W/i, " ");
		var search_value = search_value_string.split(" ");
		for (var i = 0; i < total_blocks; i++) {
			if (document.getElementById("ncp_"+i)) {
				var is_match = 0;
				var text_name = document.getElementById("ncpn_"+i).innerHTML.toLowerCase();
				var text_phn = document.getElementById("ncpp_"+i).innerHTML.toLowerCase();
				for (var p in search_value) {
					var match_name = text_name.search(search_value[p]);
					var match_phn = text_phn.search(search_value[p]);
					if (match_name > -1 || match_phn > -1) {
						is_match = 1;
					}
				}
				if (is_match == 1) {
					document.getElementById("ncp_"+i).className = "float-l w25p show";
				} else {
					document.getElementById("ncp_"+i).className = "float-l w25p hide";
				}
			}
		}
	}
}