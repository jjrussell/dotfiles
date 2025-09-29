#!/bin/sh

# path to the folder containing all of the pop mail.
POP_DIR="$HOME/.evolution/mail/local"

echo "Starting spam training on `date`"
echo "Analyzing SPAM_TRAINING folder..."



sa-learn --spam --mbox --showdots --no-sync "$POP_DIR/Inbox.sbd/Geek Stuff.sbd/SPAM_TRAINING"

echo "Analyzing Ham Training folders..."

sa-learn --ham --mbox --showdots --no-sync "$POP_DIR/Inbox.sbd/Family"
sa-learn --ham --mbox --showdots --no-sync "$POP_DIR/Inbox.sbd/Humor"
sa-learn --ham --mbox --showdots --no-sync "$POP_DIR/Inbox.sbd/Friends"
sa-learn --ham --mbox --showdots --no-sync "$POP_DIR/Inbox.sbd/Entertainment"
sa-learn --ham --mbox --showdots --no-sync "$POP_DIR/Inbox.sbd/eCommerce.sbd/bmg"

sa-learn --sync

echo "Done."
