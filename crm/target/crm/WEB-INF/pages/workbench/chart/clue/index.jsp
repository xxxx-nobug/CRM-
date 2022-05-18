<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <!--引入jquery-->
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <!--引入echarts插件-->
    <script type="text/javascript" src="jquery/echarts/echarts.min.js"></script>
    <title></title>
    <script type="text/javascript">
        $(function () {
            // 发送查询请求
            $.ajax({
                url:'workbench/chart/clue/queryCountOfClueGroupByStage.do',
                type:'post',
                dataType:'json',
                success:function (data) {
                    // 调用echarts工具函数，显示漏斗图
                    // 基于准备好的dom，初始化echarts实例
                    var myChart = echarts.init(document.getElementById('main'));

                    // 指定图表的配置项和数据
                    var option = {
                        title: {
                            text: '线索柱状图'
                        },
                        xAxis: {
                            type: 'category',
                            data: data.clueStage
                        },
                        yAxis: {
                            type: 'value'
                        },
                        series: [
                            {
                                data: data.counts,
                                type: 'bar',
                                showBackground: true,
                                backgroundStyle: {
                                    color: 'rgba(180, 180, 180, 0.2)'
                                }
                            }
                        ]
                    };

                    // 使用刚指定的配置项和数据显示图表。
                    myChart.setOption(option);
                }
            });
        });
    </script>
</head>
<body>
<!-- 为ECharts准备一个具备大小（宽高）的Dom -->
<div id="main" style="width: 1000px;height:600px; margin: 0 auto"></div>
</body>
</html>
