({
	scriptsLoaded : function(component, event, helper) {
        
        var colors = [
            'rgba(23, 48, 91, 1)',
            'rgba(62, 159, 222, 1)',
            'rgba(48, 165, 154, 1)',
            'rgba(132, 220, 214, 1)',
            'rgba(222, 159, 0, 1)',
            'rgba(223, 205, 114, 1)'
        ];
        
		var labels = [];
		var datasets = [];
        var stageRevenueMap = {};
        
        var cResponseData = component.get("v.chartData");
       
        for(var i = 0; i <= cResponseData.length - 1; i++){
            labels.push(cResponseData[i].product);
            
            var cWCList = cResponseData[i].wcList;
            for(var j = 0; j <= cWCList.length - 1; j++){
                if (stageRevenueMap[cWCList[j].stage]) {
                	stageRevenueMap[cWCList[j].stage].push(cWCList[j].sumAmount);    
                } else {
                 	stageRevenueMap[cWCList[j].stage] = [cWCList[j].sumAmount];   
                }                                
            }
        }
                
        var i=0;
        for (var key in stageRevenueMap) {
            datasets.push({
                label: key,                
                data: stageRevenueMap[key],
                fill: false,
                borderWidth: 1.5,
                backgroundColor: colors[i++],
                borderColor: colors[i],
                pointBackgroundColor: "#FFFFFF",
                pointBorderWidth: 4,
                pointHoverRadius: 8,
                pointRadius: 6,
                pointHitRadius: 10,
            });
        }
        
        var ctx = component.find("chart").getElement();
        var chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: datasets
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
        
	}
})