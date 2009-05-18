
var last_query = "";
var last_subquery = "";

function match_entry(entry, query){
    // mock-up
    if (entry.innerHTML.indexOf(query) < 0){
        return false;
    }

    return true;
}

function grep_entry(entries, query){
    for(var i = 0;i < entries.length;i++){
        var entry = entries[i];
        if(match_entry(entry, query)){
            entry.style.display = "block";
        } else {
            entry.style.display = "none";
        }
    }
}

function search(query, subquery){
    entries = $("div#entries > div.entry");
    grep_entry(entries, query);
    for(var i = 0;i < entries.length;i++){
        subsearch(entries[i], subquery);
    }
}

function subsearch(parent, subquery){
    subentries = $("div.subentries > div.subentry", parent);
    grep_entry(subentries, subquery);
}

function do_search(){
    var query = $('input#latex-query')[0].value;
    var subquery = $('input#latex-subquery')[0].value;

    if (query.length < 2 ||
        (query == last_query && subquery == last_subquery)){
        return;
    }

    last_query = query;
    last_subquery = subquery;

    search(query, subquery);
}


