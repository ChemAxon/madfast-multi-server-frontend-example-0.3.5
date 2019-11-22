"use strict";

/**
 * Index page for multi-server experiment.
 * 
 * The example exposes this file (among other files, including static data) on all launched servers, from
 * the "additional/" directory. See https://disco.chemaxon.com/products/madfast/latest/doc/rest-api-example.html
 * (section Advanced server configuration: Additional static content) for details.
 * 
 * This file is a simple EcmaScript 5 file (https://www.w3schools.com/js/js_es5.asp) used directly without further
 * compilation. 
 * 
 */

// Get MadFast WebUI client library
// See https://disco.chemaxon.com/products/madfast/latest/doc/using-webui-js-library.html
var M = window['EXPERIMENTAL-MADFAST-WEBUI'];

console.log('MadFast WebUI client library facade:', M);


// jQuery, D3 and lodash (with some extensions) are shipped in WebUI, acquire them
var $ = M.$;
var d3 = M.d3;
var _ = M._;

// Acquire used components from WebUI
var modals = M.ui.modals;
var network = M.apiclient.network;
var topmsg = M.ui.topmsg;
var progress = M.landing.progress;

// This component is responsible for the composition of the main index page of the Web UI. It is reused
// in this example, however its limitations are worked around using direct DOM manipulation. The API of
// this component is expected to accomodate this use case in a subsequent MadFast release.
var createPage = M.landing.createResourceListPage;

// to write log use query parameter "log=all", eg http://localhost:18086/additional/index.html?log=all
var log = _.getLog('multi-server-index-page').log('Index page setup');


var STATUS_DOWN = "down";
var STATUS_ONLINE = "online";
var STATUS_LOADING = "loading";

/**
 * Page components.
 * 
 * Filled by function init_index_page. These DOM references are used to update display statuses, typically from
 * response handlers.
 */
var pageComponents = {
    /**
     * D3 selection of the descriptors table tbody element.
     */
    descriptorsTableTbody : undefined,

    /**
     * D3 selection of the servers table tbody element.
     */
    serversTableTbody : undefined,
    
    /**
     * Descriptor table rows to poll (D3 selection of tr elements).
     * 
     * Poll logic:
     *   - descriptors from offline server are considered offline, not polled
     *   - non-online descriptors (from online or loading) are polled; on success they became online
     *   - online descriptors are not polled (until their server goes down)
     */
    descriptorTableTrsToPoll : []
};



/**
 * Select row in the servers table based on server info.
 * 
 * @param server Server info object
 * @returns D3 selection of the row representing the given server
 */
function selectServerTableRow(server) {
    // See https://stackoverflow.com/questions/22507072/select-d3-node-by-its-datum
    return pageComponents.serversTableTbody.selectAll('tr').filter(function(d) { return d.root === server.root; });
}

/**
 * Select rows in the descriptors table for a server,
 * 
 * @param server Server info object
 * @returns D3 selection of the rows representing descriptors served by the specified server
 */
function selectDescriptorTableRows(server) {
    // See https://stackoverflow.com/questions/22507072/select-d3-node-by-its-datum
    return pageComponents.descriptorsTableTbody.selectAll('tr').filter(function(d) { return d.server.root === server.root; });
}

/**
 * Update status request icon in the specified row(s).
 * 
 * The request) status icon (wifi icon) will be shown indicating a request was sent.
 * 
 * @param row D3 selection of the row(s) to update
 */
function status_request_sent(row) {
    row.select('.status-request-sent')
            .classed('hidden-with-fadeout', false)
            .attr('title', 'Request for status sent; waiting for reply.');
}

/**
 * Update status request icon in the specified row(s).
 * 
 * The request) status icon (wifi icon) will be faded out indicating status response (or error response) is arrived.
 * 
 * @param row D3 selection of the row(s) to update
 */
function status_response_arrived(row) {
    // Hide icon with a delay
    // Note that the css transition used for the fade out also could be used to add a delay, however when
    // the answer arrives too soon (from localhost) it could be skipped
    // See https://lodash.com/docs/4.17.15#delay
    _.delay(function() {
        row.select('.status-request-sent')
                .classed('hidden-with-fadeout', true)
                .attr('title', 'Status response / status error arrived.');
    }, 200);
}


/**
 * 
 * Start poll descriptor table rows
 */
function start_poll_descriptor_table_rows() {
    // if empty do selection
    // if not empty launch request, make delay 1s
    if (pageComponents.descriptorTableTrsToPoll.length === 0) {
        // No columns to poll; make selection
        // This is not nice
        pageComponents.descriptorsTableTbody
                .selectAll('tr:not(.success)')
                .filter(function(d) {
                    return d.server.status === STATUS_ONLINE || d.server.status === STATUS_LOADING;
                })
                .each(function() { 
                    pageComponents.descriptorTableTrsToPoll.push(d3.select(this));
                });
    }
    
    
    if (pageComponents.descriptorTableTrsToPoll.length === 0) {
        // try again later
        _.delay(start_poll_descriptor_table_rows, 1000);
    } else {
        // poll first descriptor table row
        var rowToPoll = pageComponents.descriptorTableTrsToPoll.shift();
        var rowData = rowToPoll.datum();
        status_request_sent(rowToPoll);
        
        network.get({
            url : rowData.server.root + 'rest/descriptors/' + rowData.descriptor.name,
            success : function(stat, ext) {
                status_response_arrived(rowToPoll);
                rowToPoll.classed('success', true);
                rowToPoll.select('.size-field').text(stat.size);
                _.delay(start_poll_descriptor_table_rows, 1000);
                
                rowToPoll.select('.descriptor-status-icon').attr('class', 'descriptor-status-icon fa fa-check alert-success');
            },
            error : function(stat, ext) {
                status_response_arrived(rowToPoll);
                rowToPoll.classed('danger', true);
                rowToPoll.select('.descriptor-status-icon').attr('class', 'descriptor-status-icon fa fa-times-circle alert-danger');
                _.delay(start_poll_descriptor_table_rows, 1000);
            }
        });
    }
    
}


/**
 * Start poll the status of an individual server.
 * 
 * Status request will be sent to the specific server. Based on the response the appropriate row will be updated and 
 * this method will again called with a delay. The poll delay depends on the server status: when server is loading it
 * is polled more frequently.
 * 
 * Poll delay will be applied after the response is reveived from the previous poll to avoid request piling.
 * 
 * @param server Server descriptor object
 */
function start_poll_server_status(server) {
    log('Update server status, server:', server);
    var serverTablerow = selectServerTableRow(server);
    var descriptorTableRows = selectDescriptorTableRows(server);
    
    // Update icon (wifi icon representing active request)
    status_request_sent(serverTablerow);
    
    network.get({
        url : server.root + 'rest/statistics',
        success : function(stat, ext) {
            
            log('success', stat, ext);
            
            status_response_arrived(serverTablerow);
            
            
            if (stat.loadingSuperTask.done) {
                server.status = STATUS_ONLINE;
                
                serverTablerow.select('td').attr('class', 'alert alert-success');
                serverTablerow.select('.server-status-icon').attr('class', 'server-status-icon fa fa-check');
                // serverTablerow.select('.server-status-desc').text(' Online.');
                serverTablerow.select('.server-info').selectAll('*').remove();
                serverTablerow.select('.server-info').text('Server is online with ' + stat.totalmoleculecount + ' molecules, ' + stat.totaldescriptorcount + ' molecular descriptors.');
                
                descriptorTableRows.select('td').attr('class', 'alert alert-success');
                descriptorTableRows.select('.server-status-icon').attr('class', 'server-status-icon fa fa-check');
                
            
                // Server is up, descriptors are expected to be present
                // Remove danger class from all of them
                descriptorTableRows.classed('danger', false);
                
                // update after 3 s
                // See https://lodash.com/docs/4.17.15#delay
                _.delay(function() { start_poll_server_status(server); }, 3000);
            } else {
                server.status = STATUS_LOADING;
                
                serverTablerow.select('td').attr('class', 'alert alert-warning');
                serverTablerow.select('.server-status-icon').attr('class', 'server-status-icon fa fa-spinner fa-spin');
                // serverTablerow.select('.server-status-desc').text(' Loading.');
                serverTablerow.select('.server-info').text('').selectAll('*').remove();
                
                progress.ofTask(stat.loadingSuperTask).appendProgressBarToD3(serverTablerow.select('.server-info'));
                
                // Server still loading, descriptors status might be 
                
                descriptorTableRows.select('td').attr('class', 'alert alert-warning');
                descriptorTableRows.select('.server-status-icon').attr('class', 'server-status-icon fa fa-spinner fa-spin');
                
                // update after 0.8 s
                // See https://lodash.com/docs/4.17.15#delay
                _.delay(function() { start_poll_server_status(server); }, 800);
            }
        }, 
        error : function(err, ext) {
            
            
            log('error', err, ext);
            
            server.status = STATUS_DOWN;
            
            status_response_arrived(serverTablerow);
            
            serverTablerow.select('td').attr('class', 'alert alert-danger');
            serverTablerow.select('.server-status-icon').attr('class', 'server-status-icon fa fa-times-circle');
            // serverTablerow.select('.server-status-desc').text(' Down.');
            serverTablerow.select('.server-info').selectAll('*').remove();
            serverTablerow.select('.server-info').text('Server is not accessible at the moment.');
            
            
            // Server down, mark descriptors from this server as offline
            // See https://getbootstrap.com/docs/3.3/css/#tables-contextual-classes
            descriptorTableRows.classed('danger', true);
            descriptorTableRows.classed('success', false);
            descriptorTableRows.select('td').attr('class', 'alert alert-danger');
            descriptorTableRows.select('.server-status-icon').attr('class', 'server-status-icon fa fa-times-circle');
            
            descriptorTableRows.select('.descriptor-status-icon').attr('class', 'descriptor-status-icon fa fa-times-circle alert-danger');
            
            
            // update after 3 s
            // See https://lodash.com/docs/4.17.15#delay
            _.delay(function() { start_poll_server_status(server); }, 3000);
        }
    });
}

function start_poll_all_server_status(servers) {
    for (var i = 0; i < servers.length; i++) {
        start_poll_server_status(servers[i]);
    }
}


function init_descriptors_table(page, serversArray) {
    log('Init descriptors table.');
    page.section({
        name : 'Molecular descriptors (fingerprints)',
        desc : 'List of all configured descriptors across all servers.',
        icon : '/img/desc.png' // Image icon for descriptors section is shipped with the Web UI
    });
    
    var tableElement = d3.select('#main').append('div').classed('class-details', true).append('table').classed('table table-hover', true);
    var theadRow = tableElement.append('thead').append('tr');
    theadRow.append('th').classed('col-xs-2', true).text('Server');
    theadRow.append('th').classed('col-xs-2', true).text('Name / link');
    theadRow.append('th').classed('col-xs-1', true).text('Size');
    theadRow.append('th').classed('col-xs-7', true).text('Description');
    
    // Collect data to bound
    var data = [];
    for (var i = 0; i < serversArray.length; i++) {
        var server = serversArray[i];
        for (var j = 0; j < server.descriptors.length; j++) {
            var descriptor = server.descriptors[j];
            
            data.push({
                server : server,
                descriptor : descriptor
            });
        }
    }
    log('Data to be bound to descriptor table rows:', data);
 
    var tbodyElement = tableElement.append('tbody');
    
    // Use D3 data binding to bind data to table rows
    // Each table row will be associated with one element from the data array composed above
    // Note that we dont expect to have different servers, so no update/exit statements for the binding
    var enterStatement = tbodyElement.selectAll('tr').data(data).enter().append('tr');
    
    
    // First column: server name, status icon
    var col_1 = enterStatement.append('td');
    
    col_1.append('i').classed('server-status-icon fa fa-question-circle', true);
    col_1.append('span').text(' ');
    col_1.append('code').text(function(d) { return d.server.name; });
    
    
    // Second column: descriptor status icon, name and link, status request sent icon
    var col_2 = enterStatement.append('td');
    col_2.append('i').classed('descriptor-status-icon fa fa-question-circle', true);
    col_2.append('span').text(' ');

    col_2.append('code').append('a')
            .attr('href', function(d) { return d.server.root + 'simsearch.html?ref=rest/descriptors/' + d.descriptor.name; } )
            .attr('target', '_blank')
            .attr('title', 'Open real time search from in new tab')
            .text(function(d) { return d.descriptor.name; });
    col_2.append('i').classed('status-request-sent hidden-with-fadeout fa fa-wifi pull-right', true).attr('title', 'No status request sent');
    
    // Third column: descriptor count
    enterStatement.append('td').classed('text-right', true).append('span').classed('size-field', true).text('?');
    
    // Fourth column: Description
    enterStatement.append('td').append('strong').text(function(d) { return d.descriptor.description; });
    
    return tbodyElement;
}


/**
 * Init servers table.
 * 
 * @param page Page facade
 * @param serversArray Array of server descriptors
 * @returns servers table tbody element D3 selection
 */
function init_servers_table(page, serversArray) {
    page.section({ 
        name : 'Servers', 
        desc : 'List of configured MadFast servers. Server statuses are refreshed periodically. Clicking on the server link opens the specific servers individual resource index page.', 
        icon : 'additional/img/server-icon-64.png'
    });
                
    // Compose server details table manually
    // 
    // resource list page component places this div (with ID 'main')
    // bootstrap styles are included with the Web UI JS client facade
    // custom styles are manually included by the index.html file


    var tableElement = d3.select('#main').append('div').classed('class-details', true).append('table').classed('table table-hover', true);
    var theadRow = tableElement.append('thead').append('tr');
    theadRow.append('th').classed('col-xs-3', true).text('Server name / status');
    theadRow.append('th').classed('col-xs-9', true).text('Server info');

    var tbodyElement = tableElement.append('tbody');
    
    // Use D3 data binding to bind servers data to table rows
    // Each table row will be associated with one element from the servers data array
    // Note that we dont expect to have different servers, so no update/exit statements for the binding
    var enterStatement = tbodyElement.selectAll('tr').data(serversArray).enter().append('tr');
    
    // First column: server status  icon, server name and link, status request sent icon
    var col_1 = enterStatement.append('td');
    
    col_1.append('i').classed('server-status-icon fa fa-question-circle', true);
    col_1.append('span').text(' ');
    col_1.append('code').append('a')
            .attr('href', function(d) { return d.root; } )
            .attr('target', '_blank')
            .attr('title', function(d) { return 'Open server index page from ' + d.root + ' (in new tab)'; })
            .text(function(d) { return d.name; });
    
    // col_1.append('span').classed('server-status-desc', true).text(' unknown');
    col_1.append('i').classed('status-request-sent hidden-with-fadeout fa fa-wifi pull-right', true).attr('title', 'No status request sent');
    
   
    // Second column: server info
    var col_2 = enterStatement.append('td');
    col_2.append('strong').text(function(d) { return d.description; } );
    col_2.append('div').classed('server-info', true).text('No further info available currently.');    
    
    
    return tbodyElement;
}

function init_index_page(page, data) {
    pageComponents.serversTableTbody = init_servers_table(page, data.servers);
    pageComponents.descriptorsTableTbody = init_descriptors_table(page, data.servers);

    
    start_poll_all_server_status(data.servers);
    start_poll_descriptor_table_rows();
}



$(function() {
    // Acquire servers metadata
    network.get({
        url : '/additional/data/servers-info.json',
        success : function(d) { 
            //topmsg.info('Metadata for ' +  d.servers.length + ' servers arrived.');
            log('Servers metadata', d);
            
            
            var page = createPage();
            // Page header is created by this method
            // update it manually 
            d3.select('header.top-header > span.madfast-title')
                    .text('MadFast multi server deployment example');
            
            page.stattext('Further info:','');
            page.statlink('fa fa-info', 'Show info', function() {
                modals.createModal()
                        .titleText('Info')
                        .appendMdToBody(
                            'This is a UI customization example for MadFast which connects to multiple running' +
                            'servers. Server statuses are polled periodically.\n\n' +
                            'See product page at <https://disco.chemaxon.com/products/madfast/>.'
                        )
                        .appendPToBody('Raw server description used to build this page:')
                        .appendJsonObjectToBody(d)
                        .acceptButtonText('Ok')
                        .show();
            });
            
            // The link icon just added contains '#void' as its href
            // this causes problem if the page is not the main index page
            d3.select('div.main-stats > code > a').attr('href', 'javascript:void');
            
            // Check servers metadata for addresses
            if (d.servers.length > 0 && d.servers[0].root === 'http://localhost:18085/') {
                modals.showMd('WARNING', 
                'Servers metadata seems to contain the default configuration, referencing `http://localhost:<PORT>/`.' +
                '\n\n' +
                'This configuration works **only** when the servers and the browser are launched on the same machine.');
            }
            
            init_index_page(page, d);
        },
        error : function(json) {
            modals.showErrorReport('Error accessing servers metadata,', json);
        }
    });

});
