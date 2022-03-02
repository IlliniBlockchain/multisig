<script>
	import { onMount } from 'svelte';
	import { Button } from './components'

	let connected = false;

	let network = 'Ethereum';
	let ethBalance = 0;
	let walletAddr = '0x';

	onMount(() => {
		console.log('This code happens when this component is rendered.');
	})

	const connectWallet = () => {
		alert('clicked connect wallet');
	}

</script>

<div>
	<div class='nav-bar'>

		<div class='left'>

			<div class='logo'>
				<img src='/favicon.png' alt='Illini Blockchain Logo' />
			</div>
			<div class='logo-text'>
				Illini Blockchain Multisig
			</div>

		</div>

		<div class='center'>

		</div>

		<div class='right'>

			{#if connected}
			<div class='wallet-addr'>
				{walletAddr}
			</div>
			<div class='eth-balance'>
				{ethBalance} ETH
			</div>
			<div class='network'>
				{network}
			</div>
			{:else}
			<div class='connect-wallet'>
				<Button on:click={connectWallet}>Connect Wallet</Button>
			</div>
			{/if}

		</div>

	</div>
	<div class='content'>
		<slot/>
	</div>
</div>

<style>

	.content {
		padding-top: 30px;
		max-width: 800px;
		margin: auto;
	}

	.nav-bar {
		display: flex;
		justify-content: space-between;
		width: 100%;
		height: 80px;
		padding: 20px;
	}

	.left {
		width: 33%;
		display: flex;
	}

	.logo {
		background-color: var(--dark-gray);
		width: fit-content;
		padding: 5px 5px 0px 5px;
		border-radius: 5px;
	}

	.logo-text {
		padding: 10px;
	}

	.center {
		width: 33%;
		display: flex;
		justify-content: center;
	}

	.right {
		width: 33%;
		display: flex;
		flex-direction: row-reverse;
	}

	.network, .eth-balance, .wallet-addr {
		background-color: var(--dark-gray);
		border-radius: 12px;
		padding: 10px 15px;
		margin-left: 10px;
	}

</style>