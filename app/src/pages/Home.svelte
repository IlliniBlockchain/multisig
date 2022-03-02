<script>
	import { Link } from 'svelte-routing'
	import { Button } from '../components'

	const testTxs = [
		{ pendingHash: '0x6abfasdfasdfasdf', name: "Ape entire treasury into hogecoin", executed: false },
		{ pendingHash: '0xasdfasdfasdf', name: "Donate to charity", executed: true }
	]
	export let txs = testTxs; // list
</script>

<div>
	<div class='top-bar'>
		<div class='left'>
			<h1 class='page-title'>Transactions</h1>
		</div>
		<div class='right'>
			<div><Link to='/create'><Button>Create Transaction</Button></Link></div>
			<div><Link to='/send'><Button blue>Send Money</Button></Link></div>
		</div>
	</div>
	<div class='txs'>
		{#each txs as { pendingHash, name, executed }, i}
			<Link to={'/tx/' + pendingHash}><div class='tx'>
				<p class='pending-hash'>{pendingHash.slice(0, 5)}</p>
				<h3 class='name'>{name}</h3>
				<div class={executed ? 'executed' : 'pending'}>
					{executed ? 'executed' : 'pending'}
				</div>
			</div></Link>
		{/each}
	</div>
</div>

<style>
    .page-title {
        font-weight: 500;
        font-size: 1.5rem;
    }

	.top-bar {
		display: flex;
		justify-content: space-between;
		margin-bottom: 20px;
	}

	.right {
		display: flex;
		flex-direction: row-reverse;
		padding: 10px 0px;
	}

	.right * {
		margin-left: 10px;
	}

	.txs {
		display: flex;
		flex-direction: column;
	}

	.tx {
		background-color: var(--dark-gray);
		margin-bottom: 20px;
		border-radius: 12px;
		display: flex;
		justify-content: space-between;
		padding: 10px 25px;
		transition: 0.1s;
	}

	.tx:hover {
		cursor: pointer;
		background-color: var(--darker-gray);
	}

	.pending-hash {
		width: 12%;
		padding: 5px 5px;
	}

	.name {
		width: 75%;
	}

	.pending, .executed {
		padding: 10px;
		border-radius: 10px;

		font-size: 0.9rem;
		font-weight: 600;
		text-transform: uppercase;

		padding: 8px 15px;
		width: fit-content;
		height: fit-content;
		margin: auto;
	}

	.pending {
		border: solid 1px var(--orange);
		color: var(--orange);
	}

	.executed {
		border: solid 1px var(--green);
		color: var(--green);
	}

</style>