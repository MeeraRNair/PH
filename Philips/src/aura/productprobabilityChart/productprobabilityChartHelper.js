({
    createChart : function (component) {
        var ready = component.get("v.ready");
        if (ready === false) {
            return;
        }
        var chartCanvas = component.find("chart").getElement();
        var recordId = component.get("v.recordId");
        var action = component.get("c.getreport");
        var colors = [
            'rgba(23, 48, 91, 1)',
            'rgba(62, 159, 222, 1)',
            'rgba(48, 165, 154, 1)',
            'rgba(132, 220, 214, 1)',
            'rgba(222, 159, 0, 1)',
            'rgba(223, 205, 114, 1)'
        ];
        
         action.setParams({
            "recordId": recordId
                        
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var reportResultData = JSON.parse(response.getReturnValue());
                var chartData = [];
                var chartLabels = [];
                for(var i=0; i < (reportResultData.groupingsDown.groupings.length); i++){
                    //Collect all labels for Chart.js data
                    var labelTemp = reportResultData.groupingsDown.groupings[i].label;
                    chartLabels.push(labelTemp);

                    var keyTemp = reportResultData.groupingsDown.groupings[i].key;

                    //Collect all values for Chart.js data
                    var valueTemp = reportResultData.factMap[keyTemp + '!T'].aggregates[0].value ;
                    chartData.push(valueTemp);
                }
                //Construct chart
                var chart = new Chart(chartCanvas,{
                    type: 'bar',
                    data: {
                        labels: chartLabels,
                        datasets: [
                            {
                                fill: false,
                borderWidth: 1.5,
                backgroundColor: colors[i++],
                borderColor: colors[i],
                pointBackgroundColor: "#FFFFFF",
                pointBorderWidth: 4,
                pointHoverRadius: 8,
                pointRadius: 6,
                pointHitRadius: 10,
                                data: chartData,
                                
                                
                            }
                        ]
                    },
               options: {
                responsive: false,
                legend: { display: false },
                maintainAspectRatio :true,
               	scales: {
                 xAxes: [{ stacked: true }],
                 yAxes: [{ stacked: true }]
				}
                }
                });
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message on createReport: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})