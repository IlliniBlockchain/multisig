<script>
	import { Router, Route } from 'svelte-routing';
	import { Home, CreateTx, TxInfo, SendMoney } from './pages'
	import Layout from './Layout.svelte'

	export let url = '';
</script>

<!-- App.svelte should be for routing and
	global state, i.e. wallet connection -->

<Layout>
	<Router url={url}>
		<Route path="/"><Home/></Route>
		<Route path="/create"><CreateTx/></Route>
		<Route path="/send"><SendMoney/></Route>
		<Route path="/tx/:pendingHash"><TxInfo/></Route>
	</Router>
</Layout>