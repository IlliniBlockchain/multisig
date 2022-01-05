<script>
	import { Router, Route } from 'svelte-routing';
	import { Home } from './pages'
	import Layout from './Layout.svelte'

	export let url = '';
</script>

<!-- App.svelte should be for routing and
	global state, i.e. wallet connection -->

<Layout>
	<Router url={url}>
		<Route path="/"><Home/></Route>
	</Router>
</Layout>