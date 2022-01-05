<script>
	import { Router, Route } from 'svelte-routing';
	import { Home } from './pages'
	import Layout from './Layout.svelte'
import CreateTx from './pages/CreateTx.svelte';
import SendMoney from './pages/SendMoney.svelte';
import TxInfo from './pages/TxInfo.svelte';

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