var start = graph.nodes[0][0];
var end = graph.nodes[1][2];
var result = astar.search(graph.nodes, start, end)
console.log(result)
