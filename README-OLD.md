Connecting to multiple MadFast servers example
==============================================

This is a MadFast UI customization example for a simple UI side dashboard.


Requirements
------------

  - Linux or Windows + [CygWin](https://www.cygwin.com/)
  - Java 8 (we recommend [Adopt OpenJDK](https://adoptopenjdk.net/))
  - MadFast 0.3.5 distribution (see <https://disco.chemaxon.com/products/madfast/latest/>) downloaded
  - Licenses acquired and set (see <https://disco.chemaxon.com/products/madfast/latest/doc/getting-started-guide.html>)


Getting started
---------------

  - Make sure that the MadFast distribution is available at `./madfast-cli-0.3.5/`. When Windows + CygWin used
    the distribution should be unpacked instad of placing a symlink.
  - Run `prepare.sh`
  - Run `start.sh`
  - Open `http://localhost:18085/additional/index.html` from a browser.
  - Try to stop one (`stop-server-4.sh`) or all (`stop.sh`) servers or restart them using `start.sh`. Observe the
    behavior of the overview page when servers stopped or restarted.

![](screenshot.png)


Change configured servers
-------------------------

Configuration is described in `additional/data/servers-info.json`. The servers are accessed at
`http://localhost:<PORT>`; make sure the addresses are set up properly.


Other notes
-----------

  - Output of the running servers are written into file `./server-<NUMBER>/gui.log`.
  - Details of preparation, server launch and server stop are outlined in document 
    [REST API / Web UI for similarity searches](https://disco.chemaxon.com/products/madfast/latest/doc/rest-api-example.html).
  - The Web UI extension point described in document
    [Using MadFast Web UI JS library](https://disco.chemaxon.com/products/madfast/latest/doc/using-webui-js-library.html)
  - Server status is acquired using REST API endpoint [`rest/statistics`](https://disco.chemaxon.com/products/madfast/latest/doc/enunciate/resource_StatisticsResource.html#resource_StatisticsResource_getStatistics_GET)
  - Server loading info is collection is described in document [Asynchronous server loading](https://disco.chemaxon.com/products/madfast/latest/doc/asynchronous-server-loading.html)
  - Descriptor status and size is acquired using REST API endpoint [`rest/descriptors/{desc}`](https://disco.chemaxon.com/products/madfast/latest/doc/enunciate/resource_DescriptorsResource.html#resource_DescriptorsResource_getSummaryOnDescriptor_GET)

