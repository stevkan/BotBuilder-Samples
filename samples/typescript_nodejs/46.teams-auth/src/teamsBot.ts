// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import {
  BotState,
  StatePropertyAccessor,
  TurnContext,
  UserState
} from 'botbuilder';
import {
  Dialog,
  DialogState
} from 'botbuilder-dialogs';
import { DialogBot } from './dialogBot';

export class TeamsBot extends DialogBot {
  // private dialog: Dialog;
  // private dialogState: StatePropertyAccessor<DialogState>;

  /**
   *
   * @param {ConversationState} conversationState
   * @param {UserState} userState
   * @param {Dialog} dialog
   */
  constructor( conversationState: BotState, userState: UserState, dialog: Dialog ) {
    super( conversationState, userState, dialog );

    this.conversationState = conversationState;
    this.dialog = dialog;
    this.dialogState = this.conversationState.createProperty<DialogState>( 'DialogState' );

    this.onMembersAdded( async ( context: TurnContext, next: any ): Promise<void> => {
      const membersAdded = context.activity.membersAdded;
      for ( let cnt = 0; cnt < membersAdded.length; cnt++ ) {
        if ( membersAdded[ cnt ].id !== context.activity.recipient.id ) {
          await context.sendActivity( 'Welcome to TeamsBot. Type anything to get logged in. Type \'logout\' to sign-out.' );
        }
      }

      await next();
    } );
  }

  async handleTeamsSigninVerifyState( context: TurnContext, state: any ): Promise<void> {
    await this.dialog.run( context, this.dialogState );
  }
}
