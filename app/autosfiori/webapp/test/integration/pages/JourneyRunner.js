sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/omrv/autosfiori/test/integration/pages/carList",
	"com/omrv/autosfiori/test/integration/pages/carObjectPage"
], function (JourneyRunner, carList, carObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/omrv/autosfiori') + '/test/flp.html#app-preview',
        pages: {
			onThecarList: carList,
			onThecarObjectPage: carObjectPage
        },
        async: true
    });

    return runner;
});

