var idleTime = 0;
$(document).ready(function () {
	if (document.getElementById("div_all")) {

		//Increment the idle time counter every minute.
		var idleInterval = setInterval(timerIncrement, 60000); // 1 minute

		//Zero the idle timer on mouse movement.
		$(this).mousemove(function (e) {
			idleTime = 0;
		});
		$(this).keypress(function (e) {
			idleTime = 0;
		});
	}
});
function timerIncrement() {
	idleTime = idleTime + 1;
	if (idleTime > 4) { // 5 minutes
		window.open("ajax.pl?do=lock", "hbin");
	}
}
function lock_screen_initiator() {
	$(document).ready(function () {
		window.open("ajax.pl?do=lock", "hbin");
	});
}
show_alerts = function() {
	if (document.getElementById("alerts")) {
		document.getElementById("alerts").className = "show";
		document.getElementById("alerts_hidden").className = "hide";
	}
}
hide_alerts = function() {
	if (document.getElementById("alerts")) {
		document.getElementById("alerts").className = "hide";
		document.getElementById("alerts_hidden").className = "show";
	}
}
manage_list_followup = function() {
	var follow_up_selection = get_selected_value("form_list_flag_for_follow_up");
	var month_array = follow_up_selection.split(" ");
	var month = month_array[0];
	var target_date = document.getElementById("form_list_flag_for_follow_up_date_"+month).innerHTML;
	document.getElementById("form_list_flag_for_follow_up_date").value = target_date;
}
manage_list = function() {

	// DISABLE MODALITY AT 6 AND 12 MONTHS
	
	var six = document.getElementById("form_list_modality_at_six_months_enable").innerHTML;
	var twelve = document.getElementById("form_list_modality_at_twelve_months_enable").innerHTML;
	if (six == 1) {
		document.getElementById("form_list_modality_at_six_months").disabled = false;
	} else {
		document.getElementById("form_list_modality_at_six_months").disabled = true;
	}
	if (twelve == 1) {
		document.getElementById("form_list_modality_at_twelve_months").disabled = false;
	} else {
		document.getElementById("form_list_modality_at_twelve_months").disabled = true;
	}

	// HIDE EVERYTHING FIRST

	document.getElementById("form_list_tn_chosen_modality_other_box").className = "hide";
	document.getElementById("form_list_incentre_reason_other_box").className = "hide";
	document.getElementById("form_list_kcc").className = "hide";
	document.getElementById("form_list_cvc").className = "hide";
	document.getElementById("form_list_incentrehd").className = "hide";
	document.getElementById("form_list_hhd").className = "hide";
	document.getElementById("form_list_pd").className = "hide";
	document.getElementById("form_list_transplant").className = "hide";
	document.getElementById("form_list_preemptive_transplant").className = "hide";

	// SELECTIVELY REVEAL INFORMATION

	if (get_selected_value("form_list_completed") == "Yes") {
		document.getElementById("form_list_tn_discharge_date").value = document.getElementById("form_list_tn_discharge_date_default").innerHTML;
	}
	if (get_selected_value("form_list_interested_in_transplant") == "Yes") {
		document.getElementById("form_list_transplant").className = "show";
	}
	if (get_selected_value("form_list_tn_chosen_modality") == "Other") {
		document.getElementById("form_list_tn_chosen_modality_other_box").className = "show";
	}
	if (get_selected_value("form_list_incentre_reason") == "Other") {
		document.getElementById("form_list_incentre_reason_other_box").className = "show";
	}
	if (get_selected_value("form_list_prior_status") == "Kidney Care Centre") {
		document.getElementById("form_list_kcc").className = "show";
	}
	if ((get_selected_value("form_list_vascular_access_at_hd_start") == "Central venous catheter (CVC)") || 
		(get_selected_value("form_list_vascular_access_at_hd_start") == "CVC with AVF or AVG")) {
		if ((get_selected_value("form_list_tn_chosen_modality") != "Peritoneal dialysis") &&
			(get_selected_value("form_list_tn_chosen_modality") != "Conservative (no dialysis)") &&
			(get_selected_value("form_list_tn_chosen_modality") != "No choice made") &&
			(get_selected_value("form_list_tn_chosen_modality") != "Other")) {
			
			// ONLY SHOW CVC OPTIONS IF THE PATIENT HAS CVC AND NOT ON PERITONEAL DIALYSIS OR CONSERVATIVE TREATMENT
			
			document.getElementById("form_list_cvc").className = "show";
		}
	}
	if ((get_selected_value("form_list_prior_status") == "Kidney Care Centre") || 
		(get_selected_value("form_list_prior_status") == "Peritoneal dialysis") || 
		(get_selected_value("form_list_prior_status") == "Physician office")) {
		document.getElementById("form_list_preemptive_transplant").className = "show";
	}
	if ((get_selected_value("form_list_tn_chosen_modality") == "In-centre hemodialysis") ||
		(get_selected_value("form_list_tn_chosen_modality") == "Nocturnal in-centre hemodialysis") ||
		(get_selected_value("form_list_tn_chosen_modality") == "Community hemodialysis")) {
		document.getElementById("form_list_incentrehd").className = "show";
	} else if (get_selected_value("form_list_tn_chosen_modality") == "Home hemodialysis") {
		document.getElementById("form_list_hhd").className = "show";
	} else if (get_selected_value("form_list_tn_chosen_modality") == "Peritoneal dialysis") {
		document.getElementById("form_list_pd").className = "show";
	} else if (get_selected_value("form_list_tn_chosen_modality") == "Transplant") {
		document.getElementById("form_list_transplant").className = "show";
	}
}
tt = function(root,active,total) {
	for (var i=0; i<=total; i++) {
		document.getElementById(root+i).className = "tab tabOff b";
	}
	document.getElementById(root+active).className = "tab tabAct b";
//	if (active < 5) {
//		show_alerts();
//	} else {
//		hide_alerts();
//	}
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
	}
}
blurry = function() {
	this.blur();
	$("html, body").animate({ scrollTop: 0 }, "slow");
}
unlock_screen = function() {
	var div_target = parent.document.getElementById("lockscreen");
	var div_close = parent.document.getElementById("div_all");
	div_target.className = "hide";
	div_close.className = "show";
}
lock_screen = function() {
	var div_content = document.getElementById("transfer").innerHTML;
	var div_target = parent.document.getElementById("lockscreen");
	var div_close = parent.document.getElementById("div_all");
	div_target.innerHTML = div_content;
	div_target.className = "show";
	div_close.className = "hide";
}
pop_up_show = function() {
	var p_obj;
	var c_obj;
	if (document.getElementById("div_pop_up_bg")) {
		p_obj = document.getElementById("div_pop_up_bg");
		c_obj = document.getElementById("div_pop_up_container");
		blurry();
	} else {
		p_obj = parent.document.getElementById("div_pop_up_bg");
		c_obj = parent.document.getElementById("div_pop_up_container");
	}
	var t_h = getElementHeight("div_all");
	p_obj.style.height = t_h+"px";
	p_obj.className = "show";
	var bg_w = getElementWidth("div_pop_up_bg");
	c_obj.style.left = Math.round(bg_w/2-490)+"px";
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
	c_obj.style.left = Math.round(bg_w/2-490)+"px";
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
	var url = "ajax.pl?token="+token+"&do=set_duration&start="+start+"&duration="+duration;
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
		} else if (abx == "Cephalexin") {
			set_antibiotics_preset("Cephalexin", "500", "500", "500", "no", "mg", "BID", "PO", "14", "");
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
	if (document.getElementById("form_case_case_type") && document.getElementById("lang").innerHTML == 'en') {
		move_to("def","form_case_case_type");
		document.getElementById("def").className = "show";
	}
}
hide_def = function() {
	document.getElementById("def").className = "hide";
}
init_new_case_ajax = function() {
	document.getElementById("new_case_no_ajax").className = "hide";
	document.getElementById("new_case_ajax").className = "show";
}
refresh_patient_selector_ajax = function(search_value_string) {
	var token = document.getElementById("form_patient_selector_token").innerHTML;
	var mode = document.getElementById("form_patient_selector_mode").innerHTML;
	var prev = document.getElementById("form_patient_selector_prev").innerHTML;
	if (search_value_string == "" || search_value_string.length < 2) {
		document.getElementById("form_patient_selector").innerHTML = "";
	} else {
		if (prev != search_value_string) {
			document.getElementById("form_patient_selector").innerHTML = document.getElementById("form_patient_selector_searching").innerHTML;
			var url = "ajax.pl?token="+token+"&add_select_patient_mode="+mode+"&do=add_select_patient&add_select_patient_query="+search_value_string;
			document.getElementById("hbin").src = url;
		}
		document.getElementById("form_patient_selector_prev").innerHTML = search_value_string;
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