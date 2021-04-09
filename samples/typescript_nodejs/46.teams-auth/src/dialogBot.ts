// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import {
    BotState,
    ConversationState,
    StatePropertyAccessor,
    TeamsActivityHandler,
    TurnContext,
    UserState
} from 'botbuilder';
import {
    Dialog,
    DialogState
} from 'botbuilder-dialogs';

export class DialogBot extends TeamsActivityHandler {
    public conversationState: BotState;
    public userState: BotState;
    public dialog: Dialog;
    private dialogState: StatePropertyAccessor<DialogState>;

    /**
     *
     * @param {ConversationState} conversationState
     * @param {UserState} userState
     * @param {Dialog} dialog
     */
    constructor( conversationState: BotState, userState: BotState, dialog: Dialog ) {
        super();
        if ( !conversationState ) throw new Error( '[DialogBot]: Missing parameter. conversationState is required' );
        if ( !userState ) throw new Error( '[DialogBot]: Missing parameter. userState is required' );
        if ( !dialog ) throw new Error( '[DialogBot]: Missing parameter. dialog is required' );

        this.conversationState = conversationState as ConversationState;
        this.userState = userState as UserState;
        this.dialog = dialog;
        this.dialogState = this.conversationState.createProperty<DialogState>( 'DialogState' );

        this.onMessage( async ( context: TurnContext, next: any ): Promise<void> => {
            console.log( 'Running dialog with Message Activity.' );

            // Run the Dialog with the new message Activity.
            await this.dialog.run( context, this.dialogState );

            await next();
        } );
    }

    /**
     * Override the ActivityHandler.run() method to save state changes after the bot logic completes.
     */
    async run( context: TurnContext ): Promise<void> {
        await super.run( context );

        // Save any state changes. The load happened during the execution of the Dialog.
        await this.conversationState.saveChanges( context, false );
        await this.userState.saveChanges( context, false );
    }
}
