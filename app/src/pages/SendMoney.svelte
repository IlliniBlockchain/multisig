<script>
	// Dummy code for input
	let amount = 0;
</script>

<div class='container'>
	<label>
		<input type=number bind:value={amount} min=0>
	</label>

	<p>{amount}</p>
</div>


<style>
    .container {
        background-color: var(--dark-gray);
        min-height: 600px;
        border-radius: 12px;
        padding: 25px 35px;
		display: flex;
		flex-direction: column;
    }

</style>